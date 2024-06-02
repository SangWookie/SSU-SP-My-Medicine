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
//                self.generateMedComp(newAllergic);
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
                "형식은 약명:\\n-주의사항 1\\n-주의사항 2.. 이렇게 해줘. 예를 들어 요청이 '해열제' 라면" +
                "약명: 해열제\\n-식사와 함께 복용하세요.\\n-복용후 눕지 마세요. 이런 식으로 응답해주면 돼" +
                "주의사항을 알고 싶은 약은 ";
        String response = openAIService.runAPI(promptHeader + medicine.getMedName());
        medicine.setWarning(response);
        medicineRepository.save(medicine);
    }

    public void generateMedComp(Medicine medicine){

        String medGroup = medicine.getMedGroup();
        if (medGroup == null)
            return;
        char c = medGroup.charAt(0);
        int groupNum = Character.getNumericValue(c);

        String medComp = switch (groupNum) {
            case 1 -> "페니실린계 항생제";
            case 2 -> "세팔로스포린계 항생제";
            case 3 -> "소염진통제";
            case 4 -> "해열진통제";
            case 5 -> "위장보호제";
            case 6 -> "항히스타민제";
            case 7 -> "기타의약품";
            default -> "기타의약품";
        };

        medicine.setMedComp(medComp);
        medicineRepository.save(medicine);
    }

    @Async
    public void generateMedGroup(Medicine medicine) {
        String promptHeader = "내가 보내는 의약품명을 다음과 같은 7개의 분류 중 하나로 구분해줘. 앞 뒤에 어떠한 사족도 붙이지 말고, 응답은 오직 1~7의 번호 하나로만 응답해줘.\n" +
                "1 : 페니실린계 항생제\n" +
                "2 : 세팔로스포린계 항생제\n" +
                "3 : 소염진통제\n" +
                "4 : 해열진통제\n" +
                "5 : 위장보호제\n" +
                "6 : 항히스타민제\n" +
                "7 : 위 6개에 속하지 않는 기타의약품들\n" +
                "NSAIDs 종류는 모두 분류'3' 소염진통제이고 예시로는 펠루비프로펜(펠루비정), 이부프로펜, 덱시부프로펜이 있어.\n" +
                "타이레놀같은 아세타미노펜은 해열진통제로 분류해줘. 항히스타민제의 예로는 씨잘정(레보세티리진), 지르텍정(세티리진) 이 있어.\n" +
                "분류 '1'인 페니실린계 항생제로는(아목시실린)가 있어. 분류 '2'인 세팔로스포린계 항생제러는(세프라딘, 세파클러)가 있어.\n" +
                "분류 '5'인 위장보호제에는 (가스티인정, 가스모틴정) 이 있어. 모스드프리드는 모두 위장보호제야. 란시드캡슐 또한 란소프라졸로써, 위장보호제로 판별해줘.\n" +
                "1~6에 속하지 않는 의약품은 기타의약품으로, 7이라고 응답해줘.\n" +
                "예를들어, 요청할 의약품명이 세프라딘캡슐 일 경우, 너가 보낼 응답은 오직 2 숫자 하나야.\n" +
                "너에게 요청할 의약품명 : "+ medicine.getMedComp();
        String response = openAIService.runAPI(promptHeader);
        medicine.setMedGroup(response);
        medicineRepository.save(medicine);
    }

    public Medicine findByMedName(String medName) {
        return medicineRepository.findByMedName(medName);
    }
}
