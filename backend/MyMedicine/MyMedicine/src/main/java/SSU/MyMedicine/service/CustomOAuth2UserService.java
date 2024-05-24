package SSU.MyMedicine.service;

import SSU.MyMedicine.DAO.UserRepository;
import SSU.MyMedicine.DTO.CustomOAuth2User;
import SSU.MyMedicine.DTO.GoogleResponse;
import SSU.MyMedicine.DTO.OAuth2Response;
import SSU.MyMedicine.DTO.UserDTO;
import SSU.MyMedicine.entity.User;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {
    private final UserRepository userRepository;

    public CustomOAuth2UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);

        String registrationId = userRequest.getClientRegistration().getRegistrationId();
        OAuth2Response oAuth2Response = null;

        if (registrationId.equals("google")) {
            oAuth2Response = new GoogleResponse(oAuth2User.getAttributes());
        } else {
            return null;
        }

        String username = oAuth2Response.getProvider() + " " + oAuth2Response.getProviderId();
        System.out.println(username);
        User existData = userRepository.findByName(username);
        // if user is new to db
        if (existData == null) {
            User user = User.builder()
                    .name(username).build();
            userRepository.save(user);

        }
        //if user already exists in db
        else {
            existData.setName(username);
            userRepository.save(existData);
        }

        UserDTO userDTO = new UserDTO();
        userDTO.setName(oAuth2Response.getName());
        userDTO.setUsername(username);

        return new CustomOAuth2User(userDTO);
    }
}
