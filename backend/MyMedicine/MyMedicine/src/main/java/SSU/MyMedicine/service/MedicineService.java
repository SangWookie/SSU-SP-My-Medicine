package SSU.MyMedicine.service;

import SSU.MyMedicine.DAO.MedicineRepository;
import SSU.MyMedicine.entity.Medicine;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MedicineService {
    final private MedicineRepository medicineRepository;
    final private OpenAIService openAIService;

    final private MedicineService self;

    public MedicineService(MedicineRepository medicineRepository, OpenAIService openAIService, @Lazy MedicineService self) {
        this.medicineRepository = medicineRepository;
        this.openAIService = openAIService;
        this.self = self;
    }

    public boolean saveIfNotThere(List<String> medicineStrings) {
        if (medicineStrings.isEmpty())
            return false;

        // save if entity does not exist
        for (String medicineStr : medicineStrings) {
            if (!medicineRepository.existsByMedName(medicineStr)) {
                Medicine newAllergic = new Medicine().builder()
                        .medName(medicineStr)
                        .medComp(medicineStr)
                        .build();
                medicineRepository.save(newAllergic);
                self.generateWarning(newAllergic);
                self.generateMedComp(newAllergic);
                self.generateMedGroup(newAllergic);
            }
        }
        return true;
    }

    @Async
    @Transactional
    public void generateWarning(Medicine medicine) {
        String promptHeader = "너는 약 복용 주의사항을 알려주는 비서야. 약 이름을 넘겨주면, 해당 약의 복용 주의사항을 응답해줘. " +
                "앞에 '알겠습니다.'는 붙이지 마. 만약 주의사항을 잘 모르겠다면 \"의사나 약사에게 문의하세요\"라고 해줘. " +
                "형식은 약명:\\n-주의사항 1\\n-주의사항2.. 이렇게 해줘. 주의사항을 알고 싶은 약은 ";
        String response = openAIService.runAPI(promptHeader + medicine.getMedName());
        medicine.setWarning(response);
        medicineRepository.save(medicine);
    }

    @Async
    public void generateMedComp(Medicine medicine){
        String promptHeader = "이 의약품의 성분을 찾아서 앞뒤 아무말도 붙이지 말고 성분명만 응답해줘. '예시 응답 : 아목시실린' : ";
        String response = openAIService.runAPI(promptHeader + medicine.getMedName());
        medicine.setMedComp(response);
        medicineRepository.save(medicine);
    }

    @Async
    public void generateMedGroup(Medicine medicine) {
        String promptHeader = "만약 "+ medicine.getMedComp() +" 의약품이 페니실린 계열이면 1이라고 대답하고, 의약품이 NSAIDs이면 2 라고 대답해줘. " +
                "답변은 앞뒤 아무말도 붙이지 말고 1, 2 또는 null중 하나로만 응답해줘";
        String response = openAIService.runAPI(promptHeader);
        medicine.setMedGroup(response);
        medicineRepository.save(medicine);
    }

    public Medicine findByMedName(String medName) {
        return medicineRepository.findByMedName(medName);
    }
}
