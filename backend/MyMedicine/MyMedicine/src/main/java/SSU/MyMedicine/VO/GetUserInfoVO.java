package SSU.MyMedicine.VO;

import SSU.MyMedicine.entity.Allergic;
import SSU.MyMedicine.entity.User;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
public class GetUserInfoVO {
    private Integer uID;
    private String name;
    private List<Allergic> allergic;
    private String nickname;
    private LocalDate birthDate;
    private String gender;
    private Double height;
    private Double weight;

    @JsonProperty("uID")
    public Integer getuID(){
        return this.uID;
    }
    public void UserEntityToVO(User user){
        this.uID = user.getUid();
        this.name = user.getName();
        this.allergic = user.getAllergicList();
        this.nickname = user.getNickname();
        this.birthDate = user.getBirthDate();
        this.gender = user.getGender();
        this.height = user.getHeight();
        this.weight = user.getWeight();
    }
}
