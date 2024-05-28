package SSU.MyMedicine.entity;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Entity
public class Medicine {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "mid")
    private Integer mid;

    @Column(name = "med_name", unique = true)
    private String medName;

    @Column(name = "med_comp")
    private String medComp;

    @Column(name = "med_group")
    private String medGroup;

    @Column(name = "warning")
    private String warning;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        return this.mid.equals(((Medicine) o).mid);
    }
}
