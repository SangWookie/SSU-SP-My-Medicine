package SSU.MyMedicine.entity;

import jakarta.persistence.*;
import lombok.*;
import org.apache.commons.lang3.builder.ToStringExclude;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "uid")
    private Integer uid;

    @Column(name = "name", nullable = false, unique = true)
    private String name;

    @Column(name = "password", nullable = true)
    private String password;

    private String nickname;

    private LocalDate birthDate;

    private String gender;

    private Double height;

    private Double weight;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "user_alergic",
            joinColumns = @JoinColumn(name = "uid"),
            inverseJoinColumns = @JoinColumn(name = "aid"))
    private List<Allergic> allergicList = new ArrayList<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "user_medicine",
            joinColumns = @JoinColumn(name = "uid"),
            inverseJoinColumns = @JoinColumn(name = "mid"))
    private List<Medicine> medicineList = new ArrayList<>();

    @ToString.Exclude
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    @OrderBy("regDate desc")
    private List<Prescription> prescList = new ArrayList<>();
}
