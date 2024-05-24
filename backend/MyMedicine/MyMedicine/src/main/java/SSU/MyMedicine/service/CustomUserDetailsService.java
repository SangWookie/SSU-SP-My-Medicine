package SSU.MyMedicine.service;

import SSU.MyMedicine.DAO.UserRepository;
import SSU.MyMedicine.DTO.CustomUserDetails;
import SSU.MyMedicine.entity.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    public CustomUserDetailsService(UserRepository userRepository){
        this.userRepository = userRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

        User userData = userRepository.findByName(username);

        if (userData != null){
            return new CustomUserDetails(userData);
        }

        return null;
    }
}
