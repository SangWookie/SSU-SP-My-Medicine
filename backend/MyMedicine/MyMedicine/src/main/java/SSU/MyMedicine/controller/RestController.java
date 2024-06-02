package SSU.MyMedicine.controller;

import SSU.MyMedicine.DTO.CustomOAuth2User;
import SSU.MyMedicine.VO.*;
import SSU.MyMedicine.entity.Allergic;
import SSU.MyMedicine.entity.Medicine;
import SSU.MyMedicine.entity.Prescription;
import SSU.MyMedicine.entity.User;
import SSU.MyMedicine.service.AllergicService;
import SSU.MyMedicine.service.MedicineService;
import SSU.MyMedicine.service.PrescriptionService;
import SSU.MyMedicine.service.UserService;
import jakarta.persistence.EntityExistsException;
import jakarta.persistence.EntityNotFoundException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.transaction.Transactional;
import net.bytebuddy.asm.Advice;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.time.LocalDate;
import java.util.*;

@org.springframework.web.bind.annotation.RestController
public class RestController {

    private final UserService userService;
    private final AllergicService allergicService;
    private final PrescriptionService prescriptionService;
    private final MedicineService medicineService;

    public RestController(UserService userService, AllergicService allergicService, PrescriptionService prescriptionService, MedicineService medicineService) {
        this.userService = userService;
        this.allergicService = allergicService;
        this.prescriptionService = prescriptionService;
        this.medicineService = medicineService;
    }

    @PostMapping("/signup")
    public String signup(@RequestBody UserVO userVO) {
        if (userService.existByName(userVO.getUsername()))
            throw new EntityExistsException("Username Already Exist");

        // allergy exists
        if (!userVO.getAllergicList().isEmpty())
            allergicService.saveIfNotThere(userVO.getAllergicList());

        List<Allergic> allergicList = new ArrayList<>();
        for (String allergicInfo : userVO.getAllergicList()) {
            Allergic addAllergic = allergicService.findByInfo(allergicInfo);
            allergicList.add(addAllergic);
        }

        User user = userService.buildUserFromVO(userVO);
        user.setAllergicList(allergicList);
        userService.save(user);

        return user.toString();
    }

//    @PostMapping("/login")
//    public Integer login(@RequestBody LoginVO user) {
//        User findUser = userService.findByName(user.getUsername());
//        if (findUser == null)
//            throw new EntityNotFoundException("Username not found");
//
//        if (userService.authUser(user))
//            return findUser.getUid();
//        else
//            throw new SecurityException("Incorrect password");
//    }

    @PutMapping("/editUser")
//    @Transactional
    public ResponseEntity<String> editUser(@RequestBody UserEditVO userEditVO) {
        User user = userService.findByUid(userEditVO.getUID());

        if (!userEditVO.getAllergicList().isEmpty())
            allergicService.saveIfNotThere(userEditVO.getAllergicList());

        List<Allergic> allergicList = new ArrayList<>();
        for (String allergicInfo : userEditVO.getAllergicList()) {
            Allergic addAllergic = allergicService.findByInfo(allergicInfo);
            allergicList.add(addAllergic);
        }

        user.setAllergicList(allergicList);
        user.setNickname(userEditVO.getNickname());
        user.setBirthDate(userEditVO.getBirthDate());
        user.setGender(userEditVO.getGender());
        user.setHeight(userEditVO.getHeight());
        user.setWeight(userEditVO.getWeight());
        userService.save(user);
        return ResponseEntity.ok("edit complete");
    }

    @GetMapping("/getUserInfo")
    public GetUserInfoVO getAllergic(@RequestParam("uID") Integer uID) {
        User foundUser = userService.findByUid(uID);
        GetUserInfoVO user = new GetUserInfoVO();
        user.UserEntityToVO(foundUser);
        return user;
    }

    @PostMapping(path = "/newPresc", consumes = {MediaType.MULTIPART_FORM_DATA_VALUE})
    public ResponseEntity<Integer> savePresc(
            @ModelAttribute PrescriptionRequestModel model) throws IOException {
        Prescription newPresc = prescriptionService.save(model);
//        파이썬으로 이미지 처리하는 프로그램 실행하는 함수
        prescriptionService.runImageWarpingPy(newPresc.getImageNum());

        return ResponseEntity.ok(newPresc.getPid());
    }

    @GetMapping("/getPrescList")
    public ResponseEntity<PrescListVO> prescList(@RequestParam("uID") Integer uID) {
        User user = userService.findByUid(uID);
        return ResponseEntity.ok(new PrescListVO(userService.getPrescFromUser(user)));
    }

    @GetMapping("/getPrescInfo")
    public ResponseEntity<PrescInfo> getPrescInfo(@RequestParam("pID") Integer pID) {
        // 요청으로 들어온 처방건
        Prescription prescription = prescriptionService.findByPid(pID);
        List<Medicine> medicineList = prescription.getMedList();

        for (Medicine medicine : medicineList) {
            medicineService.generateMedComp(medicine);
        }

        // 요청 처방건의 주인 User
        User user = userService.findUserByPID(pID);
        if (user == null)
            throw new EntityNotFoundException("Prescription Not Found");

        // 요청의 User의 Prescription List로 갖고오기
        List<Prescription> prescriptionList = user.getPrescList();

        // Prescription List 순회하여 regDate + duration 검사해서
        // 겹치면 그룹 겹치는 약 검사해서 dupMedList에 넣기
        LocalDate stDate = prescription.getRegDate();
        LocalDate edDate = stDate.plusDays(prescription.getDuration());
        List<String> dupMedList = new ArrayList<>();
        for (Prescription p : prescriptionList) {
            // 동일한 Prescription은 검사하지 않음
            if (!Objects.equals(prescription.getPid(), p.getPid())) {
                LocalDate st = p.getRegDate();
                LocalDate ed = st.plusDays(p.getDuration());
                // 겹치는 날짜가 하나도 없으면
                if (edDate.isBefore(st) || stDate.isAfter(ed)) {
                    continue;
                } else {
                    // 처방전에 있는 mID 중 성분 겹치는 거 dupMedList에 추가
                    for (Medicine medPresc : medicineList) {
                        for (Medicine medUser : p.getMedList()) {
                            if (Objects.equals(medUser.getMedGroup(), medPresc.getMedGroup())) {
                                dupMedList.add(medUser.getMedName());
                                dupMedList.add(medPresc.getMedName());
                            }
                        }
                    }
                }
            }
        }
        // 중복 제거 로직
        Set<String> dupRemove = new HashSet<>(dupMedList);
        List<String> dupMed = new ArrayList<>(dupRemove);

        // 사용자의 알러지와 겹치는 약 성분 검사
        List<String> allergicMedList = new ArrayList<>();
        for (Medicine prescMed : medicineList) {
            for (Allergic allergic : user.getAllergicList()) {
                if (Objects.equals(allergic.getInfo(), prescMed.getMedComp())) {
                    allergicMedList.add(prescMed.getMedName());
                }
            }
        }

        PrescInfo prescInfo = new PrescInfo(prescription);
        prescInfo.setDuplicateMed(dupMed);
        prescInfo.setAllergicMed(allergicMedList);

        return ResponseEntity.ok(prescInfo);
    }

    @GetMapping(value = "/getPrescPic", produces = MediaType.IMAGE_JPEG_VALUE)
    public ResponseEntity<byte[]> getPrescPic(@RequestParam("pID") Integer pID) throws IOException {
        Prescription prescription = prescriptionService.findByPid(pID);
        return ResponseEntity.ok(prescriptionService.getPrescImg(prescription.getImageNum()));
    }

    @DeleteMapping("/delPresc")
    public ResponseEntity<String> delPresc(@RequestParam("pID") Integer pID) {
        Prescription prescription = prescriptionService.findByPid(pID);
        prescriptionService.delete(prescription);
        return ResponseEntity.ok("Prescription deleted with pid : " + pID);
    }

    @GetMapping("/")
    public String mainPage(@AuthenticationPrincipal CustomOAuth2User customOAuth2User) {
//        String email = SecurityContextHolder.getContext().getAuthentication().getName();
//        return email;
        String name = null;
        return "Current user: " + customOAuth2User.getUsername();
    }

    @GetMapping("/user/welcome")
    public String userWelcome(@AuthenticationPrincipal CustomOAuth2User customOAuth2User) {
        String name = null;
        return "Current user: " + customOAuth2User.getUsername();
        // Google의 경우
//        if (principal.getAttribute("name") != null) {
//            name = principal.getAttribute("name");
//        }
//        // Kakao의 경우
//        else if (principal.getAttribute("properties") != null) {
//            Map<String, Object> properties = principal.getAttribute("properties");
//            name = (String) properties.get("nickname");
//        }
//
//        if (name == null) {
//            name = "Guest";
//        }
//
//        return name + " welcome!";
    }

    @GetMapping("/status")
    public ResponseEntity<String> alive() {
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);    //status 204
    }

    @PostMapping("/error")
    public ResponseEntity<String> error(HttpServletRequest request){
        return ResponseEntity.ok("");
    }

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<String> entityNotFoundExceptionHandler(EntityNotFoundException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
    }

    @ExceptionHandler(IOException.class)
    public ResponseEntity<String> IOExceptionHandler(IOException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
    }

    @ExceptionHandler(EntityExistsException.class)
    public ResponseEntity<String> EntityExistsExceptionHandler(EntityExistsException e) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
    }

    @ExceptionHandler(SecurityException.class)
    public ResponseEntity<String> SecurityExceptionHandler(SecurityException e) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(e.getMessage());
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<String> MissingServletRequestParameterExceptionHandler(MissingServletRequestParameterException e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
    }
}
