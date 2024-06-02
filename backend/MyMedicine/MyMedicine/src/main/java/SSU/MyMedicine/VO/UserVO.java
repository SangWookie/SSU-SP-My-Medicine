package SSU.MyMedicine.VO;

import SSU.MyMedicine.entity.User;
import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class UserVO {
    private String username;
    private String password;
    private List<String> allergicList = new ArrayList<>();
    private String nickname;
    private LocalDate birthDate;
    private String gender;
    private Double height;
    private Double weight;
}
