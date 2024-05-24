package SSU.MyMedicine.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.core.annotation.Order;

import java.time.LocalDate;
import java.util.List;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Entity
public class Prescription {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "pid")
    private Integer pid;

    @Column(name = "reg_date")
    private LocalDate regDate;

    @Column(name = "duration")
    private Integer duration;

    @Column(name = "image_num")
    private String imageNum;

    @ManyToOne
    @JoinColumn(name = "uid")
    @JsonIgnore
    private User user;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "MedList",
            joinColumns = @JoinColumn(name = "pid"),
            inverseJoinColumns = @JoinColumn(name = "mid"))
    private List<Medicine> medList;
}
