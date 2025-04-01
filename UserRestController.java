package com.example.hrms.biz.user.controller.rest;

import com.example.hrms.biz.user.model.User;
import com.example.hrms.biz.user.model.criteria.UserCriteria;
import com.example.hrms.biz.user.model.dto.UserDTO;
import com.example.hrms.biz.user.service.UserService;
import com.example.hrms.common.http.model.Result;
import com.example.hrms.common.http.model.ResultPageData;
import com.example.hrms.enumation.RoleEnum;
import com.example.hrms.exception.InvalidPasswordException;
import com.example.hrms.security.SecurityUtils;
import com.example.hrms.utils.RequestUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.access.annotation.Secured;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.authentication.preauth.PreAuthenticatedAuthenticationToken;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.Collections;
import java.util.List;

@Tag(name = "User API v1")
@RestController
@RequestMapping("/api/v1/users")
public class UserRestController {

    private final UserService userService;
    private final BCryptPasswordEncoder passwordEncoder;

    public UserRestController(UserService userService) {
        this.userService = userService;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }
    @Operation(summary = "List users")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Get success",
                    content = { @Content(mediaType = "application/json",
                            array = @ArraySchema(schema = @Schema(implementation = UserDTO.Resp.class))) }),
            @ApiResponse(responseCode = "400", description = "Invalid request",
                    content = @Content) })
    @GetMapping("")
    public ResultPageData<List<UserDTO.Resp>> list(UserCriteria criteria) {
        int total = userService.count(criteria);
        ResultPageData<List<UserDTO.Resp>> response = new ResultPageData<>(criteria, total);
        if (total > 0) {
            response.setResultData(userService.list(criteria));
        } else {
            response.setResultData(Collections.emptyList());
        }
        return response;
    }

    @Operation(summary = "Get all users")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Get success",
                    content = @Content) })
    @GetMapping("/all")
    public List<User> getAllUsers() {
        return userService.getAllUsers();
    }

    @Operation(summary = "Check username and password")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Login success",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = Result.class))),
            @ApiResponse(responseCode = "400", description = "Invalid request",
                    content = @Content),
            @ApiResponse(responseCode = "401", description = "Unauthorized",
                    content = @Content)
    })
    @PostMapping("/login")
    public Result checkLogin(@RequestBody UserDTO.Req loginRequest, HttpSession session) {
        User user = userService.getUserByUsername(loginRequest.getUsername());

        if (user == null) {
            throw new UsernameNotFoundException("Username not found.");
        }

        boolean passwordMatches = passwordEncoder.matches(loginRequest.getPassword(), user.getPassword());
        if (!passwordMatches) {
            throw new InvalidPasswordException("Invalid password.");
        }

        // Store security context case
        RequestUtils.setSessionAttr(
                HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY,
                SecurityContextHolder.getContext());

        Authentication authentication = new PreAuthenticatedAuthenticationToken(user, null, SecurityUtils.getAuthorities(user.getRole_name()));
        SecurityContextHolder.getContext().setAuthentication(authentication);

        // Set session valid within 30 minutes
        RequestUtils.session(false).setMaxInactiveInterval(1800);

        return new Result("Success", "Login successful.");
    }

    @PutMapping("/update/{username}")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'SUPERVISOR')")
    public Result updateAccount(@PathVariable String username, @RequestBody UserDTO.UpdateReq userReq) {
        User existingUser = userService.getUserByUsername(username);
        if (existingUser == null) {
            return new Result("Error", "User not found.");
        }

        // Không cho phép cập nhật Username và Email
        if (!existingUser.getUsername().equals(userReq.getUsername()) ||
                !existingUser.getEmail().equals(userReq.getEmail())) {
            return new Result("Error", "Username and Email cannot be updated.");
        }

        // Lấy role của người đang đăng nhập
        RoleEnum currentUserRole = userService.getCurrentUserRole();

        // Nếu người dùng là Supervisor, cấm cập nhật Department và Role là Admin
        if ("Supervisor".equals(currentUserRole)) {
            if (userReq.getDepartmentId() != null) {
                return new Result("Error", "Supervisors are not allowed to update Department.");
            }
            if ("Admin".equals(userReq.getRole_name())) {
                return new Result("Error", "Supervisors are not allowed to assign Admin role.");
            }
        }

        // Cập nhật thông tin hợp lệ
        existingUser.setPassword(userReq.getPassword());
        existingUser.setDepartmentId(userReq.getDepartmentId());
        existingUser.setRole_name(String.valueOf(userReq.getRole_name()));
        existingUser.setSupervisor(userReq.isSupervisor());
        existingUser.setStatus(userReq.getStatus());

        userService.updateUser(existingUser);
        return new Result("Success", "Account updated successfully.");
    }
    @Operation(summary = "Delete user")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User deleted",
                    content = { @Content(mediaType = "application/json",
                            schema = @Schema(implementation = Result.class)) }),
            @ApiResponse(responseCode = "404", description = "User not found",
                    content = @Content) })
    @DeleteMapping("/{username}")
    public Result deleteUser(@PathVariable String username) {
        userService.deleteUser(username);
        return new Result("Success", "User deleted successfully.");
    }

    @Operation(summary = "Get user by username")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User found",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = User.class))),
            @ApiResponse(responseCode = "404", description = "User not found",
                    content = @Content)
    })
    @GetMapping("/getUserByUsername/{username}")
    public User getUserByUsername(@PathVariable String username) {
        User user = userService.getUserByUsername(username);
        return user != null ? user : null;
    }

    @Operation(summary = "Create account")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Account created",
                    content = { @Content(mediaType = "application/json",
                            schema = @Schema(implementation = Result.class)) }),
            @ApiResponse(responseCode = "400", description = "Invalid request",
                    content = @Content),
            @ApiResponse(responseCode = "409", description = "Conflict",
                    content = @Content) })
    @PostMapping("/create")
    @PreAuthorize("hasAnyAuthority('Admin', 'Supervisor')")
    public Result createAccount(@RequestBody UserDTO.Req userReq) {
        // Kiểm tra tính hợp lệ của username
        if (userService.getUserByUsername(userReq.getUsername()) != null) {
            return new Result("Conflict", "Username already exists.");
        }

        // Kiểm tra độ dài của tên nhân viên
        if (userReq.getUsername().length() > 50) {
            return new Result("Invalid request", "Tên nhân viên không được vượt quá 50 ký tự.");
        }

        // Tạo email dựa trên username
        String email = userReq.getUsername() + "@cmcglobal.com.vn";
        userReq.setEmail(email);

        // Kiểm tra độ dài và tính hợp lệ của mật khẩu
        if (!isValidPassword(userReq.getPassword())) {
            return new Result("Invalid request", "Mật khẩu phải dài ít nhất 10 ký tự và bao gồm chữ hoa, chữ thường và ít nhất một ký tự đặc biệt.");
        }

        // Tạo đối tượng User từ UserDTO.Req
        User user = userReq.toUser();
        userService.insertUser(user);
        return new Result("Success", "Account created successfully.");
    }

    private boolean isValidPassword(String password) {
        if (password.length() < 10) {
            return false;
        }
        boolean hasUppercase = !password.equals(password.toLowerCase());
        boolean hasLowercase = !password.equals(password.toUpperCase());
        boolean hasSpecial = password.matches(".*[^a-zA-Z0-9].*");
        return hasUppercase && hasLowercase && hasSpecial;
    }
    @GetMapping("/check")
    public Result checkUsernameExists(@RequestParam String username) {
        boolean isDuplicated = userService.isUsernameDuplicated(username);
        return new Result("Success", isDuplicated ? "Username is already taken" : "Username is available");
    }
    @PutMapping("/change-password/{username}")
    public Result changePassword(@PathVariable String username, @RequestBody UserDTO.ChangePasswordReq req) {
        User user = userService.getUserByUsername(username);
        if (user == null) {
            return new Result("Error", "User not found.");
        }

        if (!isValidlPassword(req.getNewPassword())) {
            return new Result("Error", "Mật khẩu phải lớn hơn 10 ký tự, bao gồm cả ký tự hoa thường và có ít nhất một ký tự đặc biệt.");
        }

        user.setPassword(passwordEncoder.encode(req.getNewPassword()));
        userService.updateUser(user);

        return new Result("Success", "Password changed successfully.");
    }

    private boolean isValidlPassword(String password) {
        return password.length() >= 10 &&
                password.matches(".*[A-Z].*") &&
                password.matches(".*[a-z].*") &&
                password.matches(".*[^a-zA-Z0-9].*");
    }

    @Operation(summary = "Change password")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Password changed successfully",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = Result.class))),
            @ApiResponse(responseCode = "400", description = "Invalid request",
                    content = @Content),
            @ApiResponse(responseCode = "401", description = "Unauthorized - User not logged in",
                    content = @Content),
            @ApiResponse(responseCode = "403", description = "Forbidden - Old password is incorrect",
                    content = @Content)
    })
    @PutMapping("/change-password")
    public Result changePassword(@RequestBody UserDTO.ChangePasswordReq request) {
        String username = SecurityUtils.getCurrentUsername();
        User user = userService.getUserByUsername(username);
        if (user == null) {
            return new Result("Error", "User not found.");
        }
        // Kiểm tra mật khẩu cũ có đúng không
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            return new Result("Error", "Old password is incorrect.");
        }
        // Kiểm tra mật khẩu mới có hợp lệ không
        if (!isValidPassword(request.getNewPassword())) {
            return new Result("Error", "New password must be at least 10 characters long and include uppercase, lowercase, and special character.");
        }
        // Mã hóa và cập nhật mật khẩu mới
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userService.updateUser(user);
        return new Result("Success", "Password changed successfully.");
    }

    @Operation(summary = "Logout user")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Logged out successfully",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = Result.class))),
            @ApiResponse(responseCode = "401", description = "Unauthorized - User is not logged in",
                    content = @Content)
    })
    @PostMapping("/logout")
    public Result logout(HttpSession session, HttpServletRequest request, HttpServletResponse response) {
        // Invalidate the session
        session.invalidate();

        // Remove cookies
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                cookie.setValue("");
                cookie.setPath("/");
                cookie.setMaxAge(0);
                response.addCookie(cookie);
            }
        }

        return new Result("Success", "Logged out successfully.");
    }

}