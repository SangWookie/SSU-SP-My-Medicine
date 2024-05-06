package SSU.MyMedicine.service;

import SSU.MyMedicine.DAO.UserRepository;
import SSU.MyMedicine.VO.LoginVO;
import SSU.MyMedicine.VO.UserVO;
import SSU.MyMedicine.entity.Medicine;
import SSU.MyMedicine.entity.Prescription;
import SSU.MyMedicine.entity.User;
import jakarta.persistence.EntityExistsException;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class UserService {

    private final UserRepository userRepository;

    private final BCryptPasswordEncoder bCryptPasswordEncoder;


    @Autowired
    public UserService(UserRepository userRepository, BCryptPasswordEncoder bCryptPasswordEncoder) {
        this.userRepository = userRepository;
        this.bCryptPasswordEncoder = bCryptPasswordEncoder;
    }

//    public User findById(long pid) {
//        Optional<User> result = userRepository.findById(pid);
//        User userEntity = null;
//        if (result.isPresent()) {
//            userEntity = result.get();
//        } else {
//            throw new RuntimeException("Did not find user id : " + pid);
//        }
//        return null;
//    }

    public User buildUserFromVO(UserVO user) {

        if (userRepository.existsByName(user.getUsername())) {
            throw new EntityExistsException("Member with name '" + user.getUsername() + "' already exists.");
        }

        User userEntity = User.builder()
                .name(user.getUsername())
                .password(bCryptPasswordEncoder.encode(user.getPassword()))
                .build();

        return userEntity;
    }

    public User save(User user) {
        return userRepository.save(user);
    }

    public Boolean existByName(String name) {
        if (userRepository.existsByName(name))
            return true;
        return false;
    }

    public User findByName(String username) {
        return userRepository.findByName(username);
    }

    public User findByUid(Integer uid) {
        User findUser = userRepository.findByUid(uid);
        if (findUser == null) {
            throw new EntityNotFoundException("Entity not found with uid : " + uid);
        }

        return findUser;
    }

    public boolean authUser(LoginVO user) {
        boolean login = bCryptPasswordEncoder.matches(user.getPassword(),
                userRepository.findByName(user.getUsername()).getPassword());
        return login;
    }

    public List<Integer> getPrescFromUser(User user){
        List<Prescription> prescList = user.getPrescList();
        if (prescList.isEmpty())
            return null;

        List<Integer> pidList = new ArrayList<>();
        for (Prescription presc : prescList){
            pidList.add(presc.getPid());
        }

        return pidList;
    }

    @Transactional
    public void saveMedicine(User user, List<Medicine> medicineList){
        user.setMedicineList(medicineList);
        userRepository.save(user);
    }
}
