package SSU.MyMedicine.VO;

import SSU.MyMedicine.entity.Medicine;
import SSU.MyMedicine.entity.Prescription;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@ToString
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class PrescInfo {
    private Integer pID;
    private LocalDate regDate;
    private Integer duration;
    private List<MedicineVO> medicine = new ArrayList<>();
    private String generatedInstruction = "";
    private String alert;

    @JsonProperty("pID")
    public Integer getpID(){
        return this.pID;
    }

    public PrescInfo(Prescription prescription) {
        this.pID = prescription.getPid();
        this.regDate = prescription.getRegDate();
        this.duration = prescription.getDuration();
        List<Medicine> medicineList = prescription.getMedList();
        for (Medicine med : medicineList) {
            MedicineVO medicineVO = MedicineVO.builder()
                    .medName(med.getMedName())
                    .medComp(med.getMedComp())
                    .build();
            this.medicine.add(medicineVO);
            if (med.getWarning() != null)
                this.generatedInstruction = this.generatedInstruction.concat(med.getWarning() + '\n');
        }
    }
}
