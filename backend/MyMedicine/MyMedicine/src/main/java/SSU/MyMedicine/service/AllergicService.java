package SSU.MyMedicine.service;

import SSU.MyMedicine.DAO.AllergicRepository;
import SSU.MyMedicine.entity.Allergic;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AllergicService {
    final private AllergicRepository allergicRepository;

    public AllergicService(AllergicRepository allergicRepository) {
        this.allergicRepository = allergicRepository;
    }

    public Allergic findByInfo(String info){
        return allergicRepository.findByInfo(info);
    }

    public String saveIfNotThere(List<String> allergicStrings) {
        if (allergicStrings.isEmpty())
            return "empty input";

        for (String allergicStr : allergicStrings) {
            if(!allergicRepository.existsByInfo(allergicStr)){
                Allergic newAllergic = new Allergic().builder()
                        .info(allergicStr)
                        .build();
                allergicRepository.save(newAllergic);
            }
        }
        return "save done";
    }
}
