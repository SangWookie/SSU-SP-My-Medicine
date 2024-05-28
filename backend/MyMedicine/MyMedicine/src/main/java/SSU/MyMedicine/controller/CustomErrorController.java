package SSU.MyMedicine.controller;

import io.swagger.annotations.ApiOperation;
import io.swagger.v3.oas.annotations.Hidden;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import springfox.documentation.annotations.ApiIgnore;

import java.util.*;

@Hidden
@RestController
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public ResponseEntity<Map<String, Object>> handleError(HttpServletRequest request) {
//        Map<String, Object> response = new HashMap<>();
//
//        // Request 헤더 추가
//        Map<String, String> headers = new HashMap<>();
//        Collections.list(request.getHeaderNames())
//                .forEach(headerName -> headers.put(headerName, request.getHeader(headerName)));
//        response.put("headers", headers);
//
//        // 쿠키 추가
//        List<String> cookies = new ArrayList<>();
//        if (request.getCookies() != null) {
//            for (Cookie cookie : request.getCookies()) {
//                cookies.add(cookie.getName() + "=" + cookie.getValue());
//            }
//        }
//        response.put("cookies", cookies);
        return new ResponseEntity<>(HttpStatus.OK);
    }
}
