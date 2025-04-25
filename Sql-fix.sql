CREATE DATABASE HRMS;

USE HRMS;

-- 1. TẠO CÁC BẢNG DỮ LIỆU
-- ==============================================
-- Bảng Quản lý Vai Trò (Roles)
CREATE TABLE Roles (
    role_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(64) NOT NULL UNIQUE,
    INDEX (role_name)
);

-- Bảng Quản lý Phòng Ban (Departments)
CREATE TABLE Departments (
    department_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(128) NOT NULL UNIQUE,
    status VARCHAR(10) NOT NULL DEFAULT 'active',
    INDEX (department_name)
);


-- Bảng Quản lý Người Dùng (Users)
CREATE TABLE Users (
    username VARCHAR(64) PRIMARY KEY,
    password VARCHAR(256) NOT NULL, 
    employee_name VARCHAR(128) NOT NULL,
    email VARCHAR(128) NOT NULL UNIQUE,
    department_id BIGINT,
    role_name VARCHAR(64) NOT NULL,
    is_supervisor BOOLEAN DEFAULT FALSE,
    status VARCHAR(64) NOT NULL,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id),
    FOREIGN KEY (role_name) REFERENCES Roles(role_name),
    UNIQUE (username),
    INDEX (department_id),
    INDEX (role_name),
    INDEX (status)
);

-- Bảng Yêu Cầu (Requests)
CREATE TABLE Requests (
    request_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(64) NOT NULL,
    department_id BIGINT NOT NULL,
    request_type VARCHAR(64) NOT NULL,
    request_reason TEXT DEFAULT NULL, -- KHÔNG BẮT BUỘC NẾU ĐƯỢC DUYỆT
    request_status VARCHAR(64) NOT NULL,
    approver_username VARCHAR(64) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    approved_at TIMESTAMP NULL DEFAULT NULL, -- Chi cap nhat khi duoc duyet
    rejection_reason TEXT DEFAULT NULL, -- Ly do rejected
    FOREIGN KEY (username) REFERENCES Users(username),
    FOREIGN KEY (approver_username) REFERENCES Users(username),
    INDEX (username),
    INDEX (request_status),
    INDEX (start_time),
    INDEX (end_time),
    INDEX (approver_username)
);

-- Bảng Quản lý Phòng Họp (Meeting_Rooms)
CREATE TABLE Meeting_Rooms (
    room_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_name VARCHAR(128) NOT NULL,
    location VARCHAR(256) NOT NULL,
    capacity INT NOT NULL,
    INDEX (room_name),
    INDEX (location)
);

-- Bảng Đặt Phòng Họp (Bookings)
CREATE TABLE Bookings (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(64) NOT NULL,
    room_id BIGINT NOT NULL,
    title VARCHAR(128) NOT NULL,
    attendees VARCHAR(255) NOT NULL,
    content VARCHAR(255) NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status VARCHAR(64) DEFAULT 'Requested',
    booking_type VARCHAR(32) NOT NULL, -- Loại đặt lịch
    weekdays VARCHAR(32) NULL, -- Chứa danh sách thứ nếu là 'WEEKLY' (ví dụ: 'Mo,We,Fr')
    FOREIGN KEY (username) REFERENCES Users(username),
    FOREIGN KEY (room_id) REFERENCES Meeting_Rooms(room_id),
    INDEX (username),
    INDEX (room_id),
    INDEX (start_time),
    INDEX (end_time),
    INDEX (status),
    INDEX (booking_type),
    INDEX (weekdays),
    -- Ràng buộc logic
    CHECK (start_time < end_time), -- Ngày hợp lệ
    CHECK (
        (booking_type = 'WEEKLY' AND weekdays IS NOT NULL) OR
        (booking_type IN ('ONLY', 'DAILY') AND weekdays IS NULL)
    ) -- Nếu là weekly thì weekdays phải có giá trị, ngược lại phải là NULL
);

-- Bảng Thông Báo (Notifications)
CREATE TABLE Notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    sender VARCHAR(64) NOT NULL,
    receiver VARCHAR(64) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    INDEX (sender),
    INDEX (receiver),
    INDEX (created_at),
    INDEX (is_read)
);

-- 2. CHÈN DỮ LIỆU MẪU
-- ==============================================
-- Chèn dữ liệu vào bảng Roles
INSERT INTO Roles (role_name) VALUES
('EMPLOYEE'),
('SUPERVISOR'),
('ADMIN');

-- Chèn dữ liệu vào bảng Departments
INSERT INTO Departments (department_name) VALUES
('HR'),
('Finance'),
('IT');

-- Chèn dữ liệu vào bảng Users với mật khẩu đã mã hóa và tên nhân viên
INSERT INTO Users (username, password, email, role_name, department_id, is_supervisor, status, employee_name) VALUES
('ntdu', '$2a$10$Cx7mPooZBiruz8YjaOkhTu1dlfMlHN9T5IFM8wnOp.KQTd5xzEL4q', 'ntdu@cmcglobal.vn', 'EMPLOYEE', 1, FALSE, 'Active', 'Trung Du Nguyen'),
('pmhao', '$2a$10$Cx7mPooZBiruz8YjaOkhTu1dlfMlHN9T5IFM8wnOp.KQTd5xzEL4q', 'pmhao@cmcglobal.vn', 'SUPERVISOR', 1, TRUE, 'Active', 'Minh Hao Pham'),
('bkkhanh', '$2a$10$Cx7mPooZBiruz8YjaOkhTu1dlfMlHN9T5IFM8wnOp.KQTd5xzEL4q', 'bkkhanh@cmcglobal.vn', 'ADMIN', 2, TRUE, 'Active', 'Khac Khanh Bui'),
('pnminh', '$2a$10$Cx7mPooZBiruz8YjaOkhTu1dlfMlHN9T5IFM8wnOp.KQTd5xzEL4q', 'pnminh@cmcglobal.vn', 'EMPLOYEE', 3, FALSE, 'Inactive', 'Nhat Minh Pham'),
('nhtien1', '$2a$10$Cx7mPooZBiruz8YjaOkhTu1dlfMlHN9T5IFM8wnOp.KQTd5xzEL4q', 'nhtien1@cmcglobal.vn', 'SUPERVISOR', 2, FALSE, 'Active', 'Huu Tien Pham');

-- Chèn dữ liệu vào bảng Requests
INSERT INTO Requests (username, department_id, request_type, request_reason, request_status, approver_username, start_time, end_time, rejection_reason) VALUES
('ntdu', 1, 'PAID_LEAVE', 'Nghỉ phép cá nhân', 'REJECTED', 'pmhao', '2025-02-28 09:00:00', '2025-02-28 17:00:00','Không đủ ngày nghỉ phép'),
('pmhao', 1, 'UNPAID_LEAVE', 'Nghỉ phép đột xuất', 'APPROVED', 'bkkhanh', '2025-02-27 09:00:00', '2025-02-27 17:00:00',NULL),
('nhtien1', 2, 'UNPAID_LEAVE', 'Làm việc từ xa do bệnh', 'REJECTED', 'pmhao', '2025-02-26 09:00:00', '2025-02-26 17:00:00','Chưa có giấy xác nhận'),
('bkkhanh', 2, 'PAID_LEAVE', 'Xin nghỉ phép do việc gia đình', 'REJECTED', 'bkkhanh', '2025-02-25 09:00:00', '2025-02-25 17:00:00', 'Nhân sự không đủ để thay thế'),
('pnminh', 3, 'PAID_LEAVE', 'Làm việc tại nhà', 'APPROVED', 'pmhao', '2025-02-24 09:00:00', '2025-02-24 17:00:00', NULL);

-- Chèn dữ liệu vào bảng Meeting_Rooms
INSERT INTO Meeting_Rooms (room_name, location, capacity) VALUES
('Sky Room', 'Floor 1', 10),
('Star Room', 'Floor 2', 15),
('Admin Room', 'Floor 3', 20),
('Ocean Room', 'Floor 4', 12),
('Sun Room', 'Floor 5', 8),
('Moon Room', 'Floor 6', 18);

-- Chèn dữ liệu vào bảng Bookings
-- Chèn dữ liệu vào bảng Bookings
INSERT INTO Bookings (username, room_id, title, attendees, content, start_time, end_time, status, booking_type, weekdays) VALUES
-- ONLY: Cuộc họp một lần
('ntdu', 1, 'DKR1_Training 1 (Draft)', 'ntdu, pmhao, pnminh, bkkhanh, nhtien1', 'Buổi đào tạo nội bộ', '2025-04-01 10:00:00', '2025-04-01 12:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 2, 'Finance Meeting', 'pmhao, bkkhanh', 'Thảo luận ngân sách', '2025-04-11 14:00:00', '2025-04-11 16:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 3, 'IT Strategy Session', 'bkkhanh, ntdu', 'Chiến lược IT năm 2025', '2025-04-03 09:00:00', '2025-04-03 11:00:00', 'Confirmed', 'ONLY', NULL),
('pnminh', 1, 'HR Policy Review', 'nhtien1, pmhao', 'Xem xét chính sách nhân sự', '2025-04-04 13:00:00', '2025-04-04 15:00:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 1, 'Customer Feedback Session', 'pmhao, bkkhanh', 'Lắng nghe ý kiến khách hàng', '2025-04-20 15:00:00', '2025-04-20 16:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 4, 'Ocean Retro', 'ntdu, pmhao', 'Buổi họp tổng kết quý trước', '2025-04-29 14:00:00', '2025-04-29 15:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 4, 'Ocean Brainstorm', 'ntdu, pmhao, htpham', 'Buổi brainstorm chiến lược cho quý mới', '2025-04-10 10:00:00', '2025-04-10 11:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 5, 'Sunlight Planning', 'pmhao, bkkhanh', 'Lên kế hoạch dự án ánh sáng', '2025-04-25 10:00:00', '2025-04-25 11:00:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 5, 'Sunlight Review', 'pmhao, bkkhanh', 'Xem xét tiến độ dự án ánh sáng', '2025-04-18 14:00:00', '2025-04-18 15:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 6, 'Moon Project Kickoff', 'bkkhanh, ntdu', 'Bắt đầu dự án Moonlight', '2025-04-15 15:00:00', '2025-04-15 16:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 6, 'Moon Pre-Kickoff', 'bkkhanh, ntdu', 'Chuẩn bị khởi động dự án Moon', '2025-04-20 15:00:00', '2025-04-20 16:00:00', 'Confirmed', 'ONLY', NULL),
-- DAILY: Họp từ ngày 15/04/2025 đến 17/04/2025
('ntdu', 1, 'Daily QA Sync', 'ntdu, nhtien1', 'Đồng bộ QA hàng ngày', '2025-04-15 10:30:00', '2025-04-15 11:00:00', 'Confirmed', 'DAILY', NULL),
('ntdu', 1, 'Daily QA Sync', 'ntdu, nhtien1', 'Đồng bộ QA hàng ngày', '2025-04-16 10:30:00', '2025-04-16 11:00:00', 'Confirmed', 'DAILY', NULL),
('ntdu', 1, 'Daily QA Sync', 'ntdu, nhtien1', 'Đồng bộ QA hàng ngày', '2025-04-17 10:30:00', '2025-04-17 11:00:00', 'Confirmed', 'DAILY', NULL),
-- Daily từ ngày 06/04/2025 đến 08/04/2025
('ntdu', 1, 'Daily Scrum Meeting', 'ntdu, pmhao, nhtien1', 'Họp Scrum hằng ngày', '2025-04-06 09:00:00', '2025-04-06 09:30:00', 'Confirmed', 'DAILY', NULL),
('ntdu', 1, 'Daily Scrum Meeting', 'ntdu, pmhao, nhtien1', 'Họp Scrum hằng ngày', '2025-04-07 09:00:00', '2025-04-07 09:30:00', 'Confirmed', 'DAILY', NULL),
('ntdu', 1, 'Daily Scrum Meeting', 'ntdu, pmhao, nhtien1', 'Họp Scrum hằng ngày', '2025-04-08 09:00:00', '2025-04-08 09:30:00', 'Confirmed', 'DAILY', NULL),
-- Daily từ ngày 11/04/2025 đến 12/04/2025
('pmhao', 2, 'Daily Standup', 'pmhao, bkkhanh', 'Cập nhật công việc hằng ngày', '2025-04-11 09:00:00', '2025-04-11 09:30:00', 'Confirmed', 'DAILY', NULL),
('pmhao', 2, 'Daily Standup', 'pmhao, bkkhanh', 'Cập nhật công việc hằng ngày', '2025-04-12 09:00:00', '2025-04-12 09:30:00', 'Confirmed', 'DAILY', NULL),
-- Daily từ ngày 10/04/2025 đến 11/04/2025
('ntdu', 4, 'Daily Ocean Sync', 'ntdu,nhtien1', 'Họp cập nhật tiến độ', '2025-04-10 09:00:00', '2025-04-10 09:30:00', 'Confirmed', 'DAILY', NULL),
('ntdu', 4, 'Daily Ocean Sync', 'ntdu, nhtien1', 'Họp cập nhật tiến độ', '2025-04-11 09:00:00', '2025-04-11 09:30:00', 'Confirmed', 'DAILY', NULL),
-- Daily từ ngày 21/04/2025 đến 22/04/2025
('ntdu', 4, 'Daily Ocean Sync', 'ntdu, nhtien1', 'Họp cập nhật tiến độ', '2025-04-21 09:00:00', '2025-04-21 09:30:00', 'Confirmed', 'DAILY', NULL),
('ntdu', 4, 'Daily Ocean Sync', 'ntdu, nhtien1', 'Họp cập nhật tiến độ', '2025-04-22 09:00:00', '2025-04-22 09:30:00', 'Confirmed', 'DAILY', NULL),
-- Daily từ ngày 12/04/2025 đến 13/04/2025
('pmhao', 5, 'Morning Sun Sync', 'pmhao, bkkhanh', 'Daily Morning Catch-up', '2025-04-12 08:30:00', '2025-04-12 09:00:00', 'Confirmed', 'DAILY', NULL),
('pmhao', 5, 'Morning Sun Sync', 'pmhao, bkkhanh', 'Daily Morning Catch-up', '2025-04-13 08:30:00', '2025-04-13 09:00:00', 'Confirmed', 'DAILY', NULL),
-- Daily từ ngày 23/04/2025 đến 24/04/2025
('pmhao', 5, 'Morning Sun Sync', 'pmhao, bkkhanh', 'Daily Morning Catch-up', '2025-04-23 08:30:00', '2025-04-23 09:00:00', 'Confirmed', 'DAILY', NULL),

-- MARCH 2025 - Room 1 (Sky Room)
('ntdu', 1, 'Project Kickoff', 'ntdu, pmhao, bkkhanh', 'Initial project planning session', '2025-03-01 08:00:00', '2025-03-01 09:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 2, 'HR Interview', 'pmhao, nhtien1', 'Candidate interview for HR position', '2025-03-01 10:00:00', '2025-03-01 11:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 3, 'Budget Review', 'bkkhanh, pmhao', 'Q1 budget review meeting', '2025-03-01 13:00:00', '2025-03-01 14:30:00', 'Confirmed', 'ONLY', NULL),
('pnminh', 4, 'Team Building Planning', 'pnminh, ntdu, nhtien1', 'Planning for team building event', '2025-03-01 15:00:00', '2025-03-01 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 2 (Star Room)
('bkkhanh', 2, 'Strategic Planning', 'bkkhanh, pmhao, ntdu', 'Annual strategic planning session', '2025-03-02 08:00:00', '2025-03-02 09:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 4, 'Client Meeting: ABC Corp', 'ntdu, pmhao', 'Presentation of new services', '2025-03-02 10:00:00', '2025-03-02 11:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 5, 'Training Session', 'pmhao, pnminh, nhtien1', 'New software training', '2025-03-02 13:00:00', '2025-03-02 15:00:00', 'Confirmed', 'ONLY', NULL),
('nhtien1', 6, 'Department Sync', 'nhtien1, bkkhanh', 'Weekly department synchronization', '2025-03-02 15:30:00', '2025-03-02 17:00:00', 'Confirmed', 'ONLY', NULL),

-- Room 3 (Admin Room)
('pnminh', 3, 'Product Demo', 'pnminh, ntdu, pmhao', 'New product demonstration', '2025-03-03 08:30:00', '2025-03-03 10:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 1, 'Code Review', 'ntdu, nhtien1', 'Sprint code review session', '2025-03-03 10:30:00', '2025-03-03 12:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 2, 'Executive Meeting', 'bkkhanh, pmhao', 'Monthly executive update', '2025-03-03 13:30:00', '2025-03-03 15:00:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 4, 'Recruitment Planning', 'pmhao, pnminh', 'Q2 recruitment strategy', '2025-03-03 15:30:00', '2025-03-03 17:00:00', 'Confirmed', 'ONLY', NULL),

-- Room 4 (Ocean Room)
('nhtien1', 1, 'Client Onboarding', 'nhtien1, bkkhanh', 'New client onboarding process', '2025-03-04 08:00:00', '2025-03-04 09:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 4, 'Team Feedback Session', 'pmhao, ntdu, pnminh', 'Team feedback and improvement discussion', '2025-03-04 10:00:00', '2025-03-04 11:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 2, 'Project Status Update', 'ntdu, bkkhanh', 'Weekly project status review', '2025-03-04 13:00:00', '2025-03-04 14:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 5, 'Vendor Meeting', 'bkkhanh, nhtien1', 'Meeting with technology vendors', '2025-03-04 15:00:00', '2025-03-04 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 5 (Sun Room)
('pnminh', 5, 'Marketing Strategy', 'pnminh, pmhao', 'Q2 marketing strategy planning', '2025-03-05 08:30:00', '2025-03-05 10:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 5, 'Technical Training', 'ntdu, nhtien1, bkkhanh', 'Advanced technical training session', '2025-03-05 10:30:00', '2025-03-05 12:00:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 5, 'Performance Reviews', 'pmhao, pnminh', 'Annual performance review preparation', '2025-03-05 13:30:00', '2025-03-05 15:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 5, 'Budget Planning', 'bkkhanh, ntdu', 'Q2 budget planning session', '2025-03-05 15:30:00', '2025-03-05 17:00:00', 'Confirmed', 'ONLY', NULL),

-- Room 6 (Moon Room)
('nhtien1', 6, 'Product Roadmap', 'nhtien1, pnminh, bkkhanh', 'Product roadmap planning', '2025-03-06 08:00:00', '2025-03-06 09:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 2, 'Onboarding New Employees', 'pmhao, ntdu', 'Onboarding session for new team members', '2025-03-06 10:00:00', '2025-03-06 11:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 3, 'Client Presentation', 'bkkhanh, nhtien1', 'Presentation for potential clients', '2025-03-06 13:00:00', '2025-03-06 14:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 5, 'Team Retrospective', 'ntdu, pmhao, pnminh', 'Sprint retrospective meeting', '2025-03-06 15:00:00', '2025-03-06 16:30:00', 'Confirmed', 'ONLY', NULL),

-- APRIL 2025 - Room 1 (Sky Room)
('pmhao', 1, 'Quarterly Planning', 'pmhao, bkkhanh, ntdu', 'Q2 planning session', '2025-04-01 08:00:00', '2025-04-01 09:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 2, 'Stakeholder Meeting', 'bkkhanh, nhtien1, pnminh', 'Meeting with key stakeholders', '2025-04-01 10:00:00', '2025-04-01 11:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 3, 'Technical Discussion', 'ntdu, pnminh', 'Technical architecture discussion', '2025-04-01 13:00:00', '2025-04-01 14:30:00', 'Confirmed', 'ONLY', NULL),
('nhtien1', 4, 'Team Sync', 'nhtien1, pmhao', 'Weekly team synchronization', '2025-04-01 15:00:00', '2025-04-01 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 2 (Star Room)
('pnminh', 2, 'Customer Feedback', 'pnminh, bkkhanh, ntdu', 'Review of customer feedback', '2025-04-02 08:30:00', '2025-04-02 10:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 3, 'Product Development', 'ntdu, nhtien1', 'Product development strategy', '2025-04-02 10:30:00', '2025-04-02 12:00:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 4, 'HR Policy Update', 'pmhao, bkkhanh', 'Update on HR policies', '2025-04-02 13:30:00', '2025-04-02 15:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 1, 'Investment Review', 'bkkhanh, pnminh', 'Review of Q1 investments', '2025-04-02 15:30:00', '2025-04-02 17:00:00', 'Confirmed', 'ONLY', NULL),

-- Room 3 (Admin Room)
('nhtien1', 3, 'Technical Brainstorming', 'nhtien1, ntdu, pnminh', 'Brainstorming for technical solutions', '2025-04-03 08:00:00', '2025-04-03 09:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 4, 'Financial Review', 'bkkhanh, pmhao', 'Monthly financial performance review', '2025-04-03 10:00:00', '2025-04-03 11:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 6, 'Team Building Session', 'pmhao, ntdu, nhtien1', 'Team building activities', '2025-04-03 13:00:00', '2025-04-03 14:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 2, 'Project Planning', 'ntdu, bkkhanh, pnminh', 'Planning for upcoming project', '2025-04-03 15:00:00', '2025-04-03 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 4 (Ocean Room)
('pnminh', 2, 'Sales Strategy', 'pnminh, pmhao, bkkhanh', 'Q2 sales strategy discussion', '2025-04-04 08:30:00', '2025-04-04 10:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 4, 'Architecture Review', 'ntdu, nhtien1', 'System architecture review', '2025-04-04 10:30:00', '2025-04-04 12:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 3, 'Client Meeting: XYZ Inc', 'bkkhanh, pmhao', 'Meeting with XYZ Inc representatives', '2025-04-04 13:30:00', '2025-04-04 15:00:00', 'Confirmed', 'ONLY', NULL),
('nhtien1', 5, 'Research Presentation', 'nhtien1, pnminh, ntdu', 'Presentation of recent research findings', '2025-04-04 15:30:00', '2025-04-04 17:00:00', 'Confirmed', 'ONLY', NULL),

-- Room 5 (Sun Room)
('pmhao', 5, 'Recruitment Interview', 'pmhao, bkkhanh', 'Interview for senior developer position', '2025-04-05 08:00:00', '2025-04-05 09:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 6, 'Strategic Initiative', 'bkkhanh, ntdu, nhtien1', 'Discussion on new strategic initiative', '2025-04-05 10:00:00', '2025-04-05 11:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 2, 'Technical Demo', 'ntdu, pnminh', 'Demo of new technical features', '2025-04-05 13:00:00', '2025-04-05 14:30:00', 'Confirmed', 'ONLY', NULL),
('pnminh', 1, 'Marketing Review', 'pnminh, pmhao', 'Review of marketing campaign results', '2025-04-05 15:00:00', '2025-04-05 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 6 (Moon Room)
('nhtien1', 6, 'Technology Assessment', 'nhtien1, ntdu, bkkhanh', 'Assessment of new technologies', '2025-04-06 08:30:00', '2025-04-06 10:00:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 3, 'Performance Discussion', 'pmhao, pnminh', 'Team performance discussion', '2025-04-06 10:30:00', '2025-04-06 12:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 4, 'Risk Assessment', 'bkkhanh, ntdu', 'Project risk assessment meeting', '2025-04-06 13:30:00', '2025-04-06 15:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 5, 'Sprint Planning', 'ntdu, nhtien1, pmhao', 'Next sprint planning session', '2025-04-06 15:30:00', '2025-04-06 17:00:00', 'Confirmed', 'ONLY', NULL),

-- MAY 2025 - Room 1 (Sky Room)
('bkkhanh', 1, 'Executive Committee', 'bkkhanh, pmhao', 'Monthly executive committee meeting', '2025-05-01 08:00:00', '2025-05-01 09:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 3, 'Client Onboarding: DEF Corp', 'ntdu, nhtien1, pnminh', 'Onboarding session for DEF Corp', '2025-05-01 10:00:00', '2025-05-01 11:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 5, 'Team Feedback', 'pmhao, bkkhanh', 'Team feedback collection session', '2025-05-01 13:00:00', '2025-05-01 14:30:00', 'Confirmed', 'ONLY', NULL),
('pnminh', 2, 'Product Strategy', 'pnminh, ntdu', 'Product strategy planning for Q3', '2025-05-01 15:00:00', '2025-05-01 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 2 (Star Room)
('nhtien1', 2, 'Technical Workshop', 'nhtien1, ntdu, pmhao', 'Workshop on new technologies', '2025-05-02 08:30:00', '2025-05-02 10:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 4, 'Budget Approval', 'bkkhanh, pnminh', 'Q3 budget approval meeting', '2025-05-02 10:30:00', '2025-05-02 12:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 3, 'Project Retrospective', 'ntdu, nhtien1, pmhao', 'Project completion retrospective', '2025-05-02 13:30:00', '2025-05-02 15:00:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 1, 'Recruitment Strategy', 'pmhao, bkkhanh', 'Q3 recruitment strategy planning', '2025-05-02 15:30:00', '2025-05-02 17:00:00', 'Confirmed', 'ONLY', NULL),

-- Room 3 (Admin Room)
('pnminh', 3, 'Marketing Campaign', 'pnminh, ntdu, bkkhanh', 'Planning for new marketing campaign', '2025-05-03 08:00:00', '2025-05-03 09:30:00', 'Confirmed', 'ONLY', NULL),
('nhtien1', 3, 'Technical Design', 'nhtien1, pnminh', 'System design discussion', '2025-05-03 10:00:00', '2025-05-03 11:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 3, 'Investor Meeting', 'bkkhanh, pmhao', 'Meeting with potential investors', '2025-05-03 13:00:00', '2025-05-03 14:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 3, 'Team Recognition', 'ntdu, nhtien1, pnminh', 'Team achievement recognition event', '2025-05-03 15:00:00', '2025-05-03 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 4 (Ocean Room)
('pmhao', 4, 'Department Strategy', 'pmhao, bkkhanh, ntdu', 'Department strategy for H2', '2025-05-04 08:30:00', '2025-05-04 10:00:00', 'Confirmed', 'ONLY', NULL),
('pnminh', 5, 'Product Launch Planning', 'pnminh, nhtien1', 'Planning for upcoming product launch', '2025-05-04 10:30:00', '2025-05-04 12:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 2, 'Financial Analysis', 'bkkhanh, pmhao', 'Analysis of Q1 financial performance', '2025-05-04 13:30:00', '2025-05-04 15:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 1, 'Technical Implementation', 'ntdu, nhtien1, pnminh', 'Discussion on technical implementation', '2025-05-04 15:30:00', '2025-05-04 17:00:00', 'Confirmed', 'ONLY', NULL),

-- Room 5 (Sun Room)
('nhtien1', 5, 'Research Planning', 'nhtien1, ntdu, bkkhanh', 'Planning for research initiatives', '2025-05-05 08:00:00', '2025-05-05 09:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 6, 'Team Development', 'pmhao, pnminh', 'Team professional development session', '2025-05-05 10:00:00', '2025-05-05 11:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 2, 'Strategic Partnership', 'bkkhanh, ntdu', 'Meeting with strategic partners', '2025-05-05 13:00:00', '2025-05-05 14:30:00', 'Confirmed', 'ONLY', NULL),
('pnminh', 3, 'Market Analysis', 'pnminh, nhtien1, pmhao', 'Review of market analysis results', '2025-05-05 15:00:00', '2025-05-05 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 6 (Moon Room)
('ntdu', 6, 'Client Strategy Session', 'ntdu, bkkhanh, pnminh', 'Strategic planning with key client', '2025-05-06 08:30:00', '2025-05-06 10:00:00', 'Confirmed', 'ONLY', NULL),
('nhtien1', 1, 'Innovation Workshop', 'nhtien1, pmhao', 'Workshop for innovative ideas', '2025-05-06 10:30:00', '2025-05-06 12:00:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 3, 'Career Development', 'pmhao, ntdu, bkkhanh', 'Career development discussion for team', '2025-05-06 13:30:00', '2025-05-06 15:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 5, 'Annual Planning', 'bkkhanh, pnminh, nhtien1', 'Mid-year review of annual plan', '2025-05-06 15:30:00', '2025-05-06 17:00:00', 'Confirmed', 'ONLY', NULL),

-- Additional bookings to reach 100 total
-- Room 1 (Sky Room) - Extra dates
('ntdu', 1, 'Product Roadmap Review', 'ntdu, pnminh, bkkhanh', 'Review of product roadmap for Q3', '2025-05-10 08:00:00', '2025-05-10 09:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 2, 'Team Training', 'pmhao, nhtien1', 'Training session for team members', '2025-05-10 10:00:00', '2025-05-10 11:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 3, 'Executive Planning', 'bkkhanh, pmhao', 'Executive planning session', '2025-05-10 13:00:00', '2025-05-10 14:30:00', 'Confirmed', 'ONLY', NULL),
('pnminh', 4, 'Customer Survey Results', 'pnminh, ntdu, nhtien1', 'Review of customer survey results', '2025-05-10 15:00:00', '2025-05-10 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 2 (Star Room) - Extra dates
('bkkhanh', 2, 'Strategic Review', 'bkkhanh, pmhao, ntdu', 'Mid-year strategic review', '2025-05-15 08:00:00', '2025-05-15 09:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 3, 'Client Meeting: GHI Ltd', 'ntdu, pmhao', 'Meeting with GHI Ltd representatives', '2025-05-15 10:00:00', '2025-05-15 11:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 5, 'Onboarding Improvement', 'pmhao, pnminh, nhtien1', 'Discussion on improving onboarding process', '2025-05-15 13:00:00', '2025-05-15 15:00:00', 'Confirmed', 'ONLY', NULL),
('nhtien1', 1, 'Technical Sync', 'nhtien1, bkkhanh', 'Technical team synchronization', '2025-05-15 15:30:00', '2025-05-15 17:00:00', 'Confirmed', 'ONLY', NULL),

-- Room 3 (Admin Room) - Extra dates
('pnminh', 4, 'Marketing Innovation', 'pnminh, ntdu, pmhao', 'Innovative marketing strategies discussion', '2025-05-20 08:30:00', '2025-05-20 10:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 5, 'Code Quality Review', 'ntdu, nhtien1', 'Review of code quality standards', '2025-05-20 10:30:00', '2025-05-20 12:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 1, 'Business Development', 'bkkhanh, pmhao', 'Business development strategy', '2025-05-20 13:30:00', '2025-05-20 15:00:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 2, 'Performance Optimization', 'pmhao, pnminh', 'Team performance optimization discussion', '2025-05-20 15:30:00', '2025-05-20 17:00:00', 'Confirmed', 'ONLY', NULL),

-- Room 4 (Ocean Room) - Extra dates
('nhtien1', 4, 'Client Relationship', 'nhtien1, bkkhanh', 'Client relationship management strategies', '2025-05-25 08:00:00', '2025-05-25 09:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 2, 'Employee Satisfaction', 'pmhao, ntdu, pnminh', 'Discussion on employee satisfaction survey results', '2025-05-25 10:00:00', '2025-05-25 11:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 5, 'Project Update', 'ntdu, bkkhanh', 'Project status update meeting', '2025-05-25 13:00:00', '2025-05-25 14:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 1, 'Partnership Discussion', 'bkkhanh, nhtien1', 'Discussion with potential partners', '2025-05-25 15:00:00', '2025-05-25 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 4 (Ocean Room) - Extra dates
('nhtien1', 4, 'Client Relationship', 'nhtien1, bkkhanh', 'Client relationship management strategies', '2025-04-25 08:00:00', '2025-04-25 09:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 2, 'Employee Satisfaction', 'pmhao, ntdu, pnminh', 'Discussion on employee satisfaction survey results', '2025-04-25 10:00:00', '2025-04-25 11:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 5, 'Project Update', 'ntdu, bkkhanh', 'Project status update meeting', '2025-04-25 13:00:00', '2025-04-25 14:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 1, 'Partnership Discussion', 'bkkhanh, nhtien1', 'Discussion with potential partners', '2025-04-25 15:00:00', '2025-04-25 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 4 (Ocean Room) - Extra dates
('nhtien1', 4, 'Client Relationship', 'nhtien1, bkkhanh', 'Client relationship management strategies', '2025-04-26 08:00:00', '2025-04-26 09:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 2, 'Employee Satisfaction', 'pmhao, ntdu, pnminh', 'Discussion on employee satisfaction survey results', '2025-04-26 10:00:00', '2025-04-26 11:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 5, 'Project Update', 'ntdu, bkkhanh', 'Project status update meeting', '2025-04-25 13:00:00', '2025-04-26 14:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 1, 'Partnership Discussion', 'bkkhanh, nhtien1', 'Discussion with potential partners', '2025-04-26 15:00:00', '2025-04-26 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 4 (Ocean Room) - Extra dates
('nhtien1', 4, 'Client Relationship', 'nhtien1, bkkhanh', 'Client relationship management strategies', '2025-04-27 08:00:00', '2025-04-27 09:30:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 2, 'Employee Satisfaction', 'pmhao, ntdu, pnminh', 'Discussion on employee satisfaction survey results', '2025-04-27 10:00:00', '2025-04-27 11:30:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 5, 'Project Update', 'ntdu, bkkhanh', 'Project status update meeting', '2025-04-25 13:00:00', '2025-04-27 14:30:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 1, 'Partnership Discussion', 'bkkhanh, nhtien1', 'Discussion with potential partners', '2025-04-27 15:00:00', '2025-04-27 16:30:00', 'Confirmed', 'ONLY', NULL),

-- Room 5 (Sun Room) - Extra dates
('pnminh', 5, 'Product Enhancement', 'pnminh, pmhao', 'Discussion on product enhancement ideas', '2025-05-30 08:30:00', '2025-05-30 10:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 2, 'Security Training', 'ntdu, nhtien1, bkkhanh', 'Security best practices training', '2025-05-30 10:30:00', '2025-05-30 12:00:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 4, 'Resource Allocation', 'pmhao, pnminh', 'Discussion on resource allocation for Q3', '2025-05-30 13:30:00', '2025-05-30 15:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 6, 'Q3 Planning', 'bkkhanh, ntdu', 'Detailed planning for Q3', '2025-05-30 15:30:00', '2025-05-30 17:00:00', 'Confirmed', 'ONLY', NULL),

-- Room 5 (Sun Room) - Extra dates
('pnminh', 5, 'Product Enhancement', 'pnminh, pmhao', 'Discussion on product enhancement ideas', '2025-04-24 08:30:00', '2025-04-24 10:00:00', 'Confirmed', 'ONLY', NULL),
('ntdu', 2, 'Security Training', 'ntdu, nhtien1, bkkhanh', 'Security best practices training', '2025-04-24 10:30:00', '2025-04-24 12:00:00', 'Confirmed', 'ONLY', NULL),
('pmhao', 4, 'Resource Allocation', 'pmhao, pnminh', 'Discussion on resource allocation for Q3', '2025-04-24 13:30:00', '2025-04-24 15:00:00', 'Confirmed', 'ONLY', NULL),
('bkkhanh', 6, 'Q3 Planning', 'bkkhanh, ntdu', 'Detailed planning for Q3', '2025-04-24 15:30:00', '2025-04-24 17:00:00', 'Confirmed', 'ONLY', NULL);

-- Chèn dữ liệu mẫu vào bảng Notifications

INSERT INTO Notifications (title, content, sender, receiver, created_at, is_read)
VALUES 
('Phê duyệt đơn nghỉ phép', 'Đơn xin nghỉ phép của bạn đã được phê duyệt từ ngày 25/04 đến 27/04', 'bkkhanh', 'pmhao', DATE_SUB(NOW(), INTERVAL 20 MINUTE), false),
('Lịch họp phòng ban', 'Cuộc họp phòng ban sẽ diễn ra vào 14:00 ngày 22/04 tại phòng họp A', 'bkkhanh', 'ntdu', DATE_SUB(NOW(), INTERVAL 2 HOUR), false),
('Thông báo cập nhật hệ thống', 'Hệ thống sẽ bảo trì vào tối nay từ 22:00-23:00', 'bkkhanh', 'ntdu', DATE_SUB(NOW(), INTERVAL 1 DAY), true),
('Thông báo lương tháng 4', 'Lương tháng 4 đã được chuyển vào tài khoản của bạn', 'bkkhanh', 'ntdu', DATE_SUB(NOW(), INTERVAL 5 HOUR), false),
('Đánh giá hiệu suất', 'Đánh giá hiệu suất quý I/2025 sẽ diễn ra từ 01/05-10/05', 'bkkhanh', 'ntdu', DATE_SUB(NOW(), INTERVAL 2 DAY), true),

('Yêu cầu phê duyệt', 'Có một yêu cầu mới cần bạn phê duyệt từ nhân viên Nguyễn Văn A', 'ntdu', 'pmhao', DATE_SUB(NOW(), INTERVAL 10 MINUTE), false),
('Lịch phỏng vấn ứng viên', 'Bạn có lịch phỏng vấn ứng viên vào 9:00 sáng mai', 'ntdu', 'bkkhanh', DATE_SUB(NOW(), INTERVAL 3 HOUR), false),
('Kết quả đánh giá Q1', 'Kết quả đánh giá hiệu suất Q1 đã sẵn sàng để xem xét', 'ntdu', 'bkkhanh', DATE_SUB(NOW(), INTERVAL 8 HOUR), true),
('Thông báo họp Ban Giám đốc', 'Cuộc họp Ban Giám đốc sẽ diễn ra vào 8:00 ngày mai tại phòng họp VIP', 'ntdu', 'bkkhanh', DATE_SUB(NOW(), INTERVAL 7 HOUR), false),
('Yêu cầu duyệt ngân sách', 'Có yêu cầu duyệt ngân sách dự án mới từ phòng Kinh doanh', 'ntdu', 'bkkhanh', DATE_SUB(NOW(), INTERVAL 2 DAY), false);

select * from requests;
select * from bookings;

select * from users;