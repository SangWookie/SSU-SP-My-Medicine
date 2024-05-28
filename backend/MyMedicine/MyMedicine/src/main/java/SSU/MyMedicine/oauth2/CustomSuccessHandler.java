package SSU.MyMedicine.oauth2;

import SSU.MyMedicine.DAO.RefreshTokenRepository;
import SSU.MyMedicine.DAO.UserRepository;
import SSU.MyMedicine.DTO.CustomOAuth2User;
import SSU.MyMedicine.DTO.CustomUserDetails;
import SSU.MyMedicine.entity.RefreshTokenEntity;
import SSU.MyMedicine.jwt.JWTUtil;
import SSU.MyMedicine.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Collection;
import java.util.Date;
import java.util.Iterator;

@Component
public class CustomSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {
    private final JWTUtil jwtUtil;
    private final RefreshTokenRepository refreshTokenRepository;
    private final UserService userRepository;

    public CustomSuccessHandler(JWTUtil jwtUtil, RefreshTokenRepository refreshTokenRepository, UserService userRepository1) {
        this.jwtUtil = jwtUtil;
        this.refreshTokenRepository = refreshTokenRepository;
        this.userRepository = userRepository1;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
        CustomOAuth2User customUserDetails;
        String username = null;
        //OAuth2User
        if (authentication.getPrincipal() instanceof CustomOAuth2User) {
            customUserDetails = (CustomOAuth2User) authentication.getPrincipal();
            username = customUserDetails.getUsername();
        } else if (authentication.getPrincipal() instanceof CustomUserDetails) {
            // 일반 사용자일 경우 CustomOAuth2User로 변환
            username = ((CustomUserDetails) authentication.getPrincipal()).getUsername();
        }


        System.out.println("username : " + username);
        Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();
        Iterator<? extends GrantedAuthority> iterator = authorities.iterator();
        GrantedAuthority auth = iterator.next();
        String role = auth.getAuthority();

        String access = jwtUtil.createJwt("access", username, role, 24 * 3600000L); // 10 min 600000L
        String refresh = jwtUtil.createJwt("refresh", username, role, 24 * 3600000L); // 24 hours

        //Refresh 토큰 저장
        addRefreshEntity(username, refresh, 86400000L);

        response.addHeader("access", access);
        response.addCookie(createCookie("refresh", refresh));
        response.setStatus(HttpStatus.OK.value());
        response.setHeader("uID", userRepository.findByName(username).getUid().toString());
//        response.sendRedirect("http://localhost:8080/hello");
    }

    private void addRefreshEntity(String username, String refresh, Long expiredMs) {

        Date date = new Date(System.currentTimeMillis() + expiredMs);

        RefreshTokenEntity refreshEntity = new RefreshTokenEntity();
        refreshEntity.setUsername(username);
        refreshEntity.setRefresh(refresh);
        refreshEntity.setExpiration(date.toString());

        refreshTokenRepository.save(refreshEntity);
    }

    private Cookie createCookie(String key, String value) {

        Cookie cookie = new Cookie(key, value);
        cookie.setMaxAge(24 * 60 * 60); // 24 hours
        //cookie.setSecure(true); https
        cookie.setPath("/");
        cookie.setHttpOnly(true);

        return cookie;
    }
}
