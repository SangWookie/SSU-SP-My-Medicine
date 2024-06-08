package SSU.MyMedicine.service;

import SSU.MyMedicine.DAO.PrescriptionRepository;
import SSU.MyMedicine.VO.PrescriptionRequestModel;
import SSU.MyMedicine.VO.PrescriptionVO;
import SSU.MyMedicine.entity.Medicine;
import SSU.MyMedicine.entity.Prescription;
import SSU.MyMedicine.entity.User;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.FileCopyUtils;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@Service
public class PrescriptionService {
    final private PrescriptionRepository prescriptionRepository;
    final private MedicineService medicineService;
    final private UserService userService;

    @Autowired
    PrescriptionService(PrescriptionRepository prescriptionRepository, MedicineService medicineService, UserService userService) {
        this.prescriptionRepository = prescriptionRepository;
        this.medicineService = medicineService;
        this.userService = userService;
    }

    @Value("${upload.path}")
    private String uploadPath;

//    @Transactional
    public Prescription save(PrescriptionRequestModel model) throws IOException {
        // save image
        Random random = new Random();
        int randomNumber = random.nextInt(10000000);
        String imageName = model.getUID().toString() + "0000" + Integer.toString(randomNumber) + ".jpg";
        byte[] bytes = model.getImage().getBytes();
        Path path = Paths.get(uploadPath + imageName);
        Files.write(path, bytes);

        PrescriptionVO prescription = PrescriptionVO.builder()
                .uID(model.getUID())
                .duration(model.getDuration())
                .medList(model.getMedList())
                .regDate(model.getRegDate())
                .build();

        //         save new medicine to DB
        medicineService.saveIfNotThere(prescription.getMedList());

        List<Medicine> medicineList = new ArrayList<>();
        for (String medName : prescription.getMedList()) {
            Medicine medicine = medicineService.findByMedName(medName);
            medicineList.add(medicine);
        }

        User prescUser = userService.findByUid(prescription.getUID());

        Prescription newPresc = Prescription.builder()
                .regDate(prescription.getRegDate())
                .duration(prescription.getDuration())
                .medList(medicineList)
                .imageNum(imageName)
                .user(prescUser)
                .build();

        userService.saveMedicine(prescUser,medicineList);
        return prescriptionRepository.save(newPresc);
    }

    @Async
    public void runImageWarpingPy(String imageFileName) throws IOException {
        int lastDotIndex = imageFileName.lastIndexOf('.');
        String imageNum = imageFileName.substring(0, lastDotIndex);
        ProcessBuilder processBuilder = new ProcessBuilder("python3", "/home/ubuntu/warp.py", imageNum);
        processBuilder.start();
    }
    public Prescription findByPid(Integer pID){
        Prescription prescription = prescriptionRepository.findByPid(pID);
        if (prescription == null){
            throw new EntityNotFoundException("Entity not found with pid: " + pID);
        }
        return prescription;
    }
    public byte[] getPrescImg(String imgPath) throws IOException{
        InputStream imageStream = new FileInputStream(uploadPath + imgPath);
        byte[] imageBytes = null;
        imageBytes = FileCopyUtils.copyToByteArray(imageStream);
        imageStream.close();
        return imageBytes;
    }
    public void delete(Prescription prescription){
        prescriptionRepository.delete(prescription);
    }
}
