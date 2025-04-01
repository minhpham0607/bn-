package com.example.hrms.biz.request.controller.Rest;

import com.example.hrms.biz.request.model.criteria.RequestCriteria;
import com.example.hrms.biz.request.model.dto.RequestDto;
import com.example.hrms.biz.request.service.RequestService;
import com.example.hrms.biz.user.model.User;
import com.example.hrms.biz.user.service.UserService;
import com.example.hrms.common.http.criteria.Page;
import com.example.hrms.common.http.model.Result;
import com.example.hrms.common.http.model.ResultPageData;
import com.example.hrms.security.SecurityUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;

import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;

@Tag(name = "API requests")
@RestController
@RequestMapping("/api/v1/requests")
public class RequestRestController {
    private final RequestService requestService;
    private UserService userService;

    public RequestRestController(RequestService requestService, UserService userService) {
        this.requestService = requestService;
        this.userService = userService;
    }

    @Operation(summary = "List requests")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Get success",
                    content = {@Content(mediaType = "application/json",
                            array = @ArraySchema(schema = @Schema(implementation = RequestDto.Resp.class)))
                    }),
            @ApiResponse(responseCode = "400", description = "Invalid request",
                    content = @Content)})
    @GetMapping("")
    public ResultPageData<List<RequestDto.Resp>> list(Page page, RequestCriteria criteria) {
        int total = requestService.count(criteria);
        ResultPageData<List<RequestDto.Resp>> response = new ResultPageData<>(criteria, total);
        if (total > 0) {
            response.setResultData(requestService.list(page, criteria));
        } else {
            response.setResultData(Collections.emptyList());
        }
        return response;
    }
    @Operation(summary = "Get requests of staff in the same department")
    @PreAuthorize("hasRole('SUPERVISOR')")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Get success",
                    content = {@Content(mediaType = "application/json",
                            array = @ArraySchema(schema = @Schema(implementation = RequestDto.Resp.class)))
                    }),
            @ApiResponse(responseCode = "400", description = "Invalid request",
                    content = @Content),
            @ApiResponse(responseCode = "401", description = "Unauthorized - User is not logged in",
                    content = @Content)
    })
    @GetMapping("/staff-requests")
    public ResultPageData<List<RequestDto.Resp>> getRequestsForSupervisor(Page page) {
        String supervisorUsername = SecurityUtils.getCurrentUsername();
        User supervisor = userService.getUserByUsername(supervisorUsername);

        if (supervisor == null || !supervisor.isSupervisor()) {
            throw new RuntimeException("User is not a supervisor");
        }

        int total = requestService.countRequestsByDepartment(supervisor.getDepartmentId());
        ResultPageData<List<RequestDto.Resp>> response = new ResultPageData<>(new RequestCriteria(), total);
        response.setResultData(total > 0 ? requestService.getRequestsForSupervisor(page, supervisor.getDepartmentId()) : Collections.emptyList());

        return response;
    }
    @Operation(summary = "Approve or Reject Request")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Request status updated successfully",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = Result.class))),
            @ApiResponse(responseCode = "400", description = "Invalid request",
                    content = @Content),
            @ApiResponse(responseCode = "401", description = "Unauthorized - User is not logged in",
                    content = @Content),
            @ApiResponse(responseCode = "403", description = "User is not authorized",
                    content = @Content)
    })
    @PutMapping("/{requestId}/approve-reject")
    public Result approveOrRejectRequest(@PathVariable Long requestId, @RequestParam String action) {
        String supervisorUsername = SecurityContextHolder.getContext().getAuthentication().getName();
        try {
            requestService.approveOrRejectRequest(requestId, action, supervisorUsername);
            return new Result("Success", "Request " + action.toLowerCase() + "d successfully");
        } catch (IllegalArgumentException e) {
            return new Result("Error", "Invalid action: " + action);
        } catch (RuntimeException e) {
            return new Result("Error", e.getMessage());
        } catch (Exception e) {
            return new Result("Error", "An unexpected error occurred. Please try again later.");
        }
    }


}