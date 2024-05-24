package SSU.MyMedicine.VO;

import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UserEditVO {
    Integer uID;
    List<String> allergicList = new ArrayList<>();
}
