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
    request_reason TEXT NOT NULL,
    request_status VARCHAR(64) NOT NULL,
    approver_username VARCHAR(64) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
    booking_type VARCHAR(32) NOT NULL,
    weekdays VARCHAR(32) NULL,
    FOREIGN KEY (username) REFERENCES Users(username),
    FOREIGN KEY (room_id) REFERENCES Meeting_Rooms(room_id),
    INDEX (username),
    INDEX (room_id),
    INDEX (start_time),
    INDEX (end_time),
    INDEX (status),
    INDEX (booking_type),
    INDEX (weekdays)
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
('ntdu', '$2a$10$Cx7mPooZBiruz8YjaOkhTu1dlfMlHN9T5IFM8wnOp.KQTd5xzEL4q', 'trungdu@cmcglobal.com.vn', 'EMPLOYEE', 1, FALSE, 'Active', 'Trung Du Nguyen'),
('pmhao', '$2a$10$Cx7mPooZBiruz8YjaOkhTu1dlfMlHN9T5IFM8wnOp.KQTd5xzEL4q', 'minhhao@cmcglobal.com.vn', 'SUPERVISOR', 1, TRUE, 'Active', 'Minh Hao Pham'),
('bkkhanh', '$2a$10$Cx7mPooZBiruz8YjaOkhTu1dlfMlHN9T5IFM8wnOp.KQTd5xzEL4q', 'khackhanh@cmcglobal.com.vn', 'ADMIN', 2, TRUE, 'Active', 'Khac Khanh Bui'),
('pnminh', '$2a$10$Cx7mPooZBiruz8YjaOkhTu1dlfMlHN9T5IFM8wnOp.KQTd5xzEL4q', 'nhatminh@cmcglobal.com.vn', 'EMPLOYEE', 3, FALSE, 'Inactive', 'Nhat Minh Pham'),
('htpham', '$2a$10$Cx7mPooZBiruz8YjaOkhTu1dlfMlHN9T5IFM8wnOp.KQTd5xzEL4q', 'huutien@cmcglobal.com.vn', 'SUPERVISOR', 2, FALSE, 'Active', 'Huu Tien Pham');

-- Chèn dữ liệu vào bảng Requests
INSERT INTO Requests (username, department_id, request_type, request_reason, request_status, approver_username, start_time, end_time) VALUES
('ntdu', 1, 'PAID_LEAVE', 'Nghỉ phép cá nhân', 'REJECTED', 'pmhao', '2025-02-28 09:00:00', '2025-02-28 17:00:00'),
('pmhao', 1, 'UNPAID_LEAVE', 'Nghỉ phép đột xuất', 'APPROVED', 'bkkhanh', '2025-02-27 09:00:00', '2025-02-27 17:00:00'),
('htpham', 2, 'UNPAID_LEAVE', 'Làm việc từ xa do bệnh', 'REJECTED', 'pmhao', '2025-02-26 09:00:00', '2025-02-26 17:00:00'),
('bkkhanh', 2, 'PAID_LEAVE', 'Xin nghỉ phép do việc gia đình', 'REJECTED', 'bkkhanh', '2025-02-25 09:00:00', '2025-02-25 17:00:00'),
('pnminh', 3, 'PAID_LEAVE', 'Làm việc tại nhà', 'APPROVED', 'pmhao', '2025-02-24 09:00:00', '2025-02-24 17:00:00');

-- Chèn dữ liệu vào bảng Meeting_Rooms
INSERT INTO Meeting_Rooms (room_name, location, capacity) VALUES
('Sky Room', 'Floor 1', 10),
('Star Room', 'Floor 2', 15),
('Admin Room', 'Floor 3', 20);

-- Chèn dữ liệu vào bảng Bookings
INSERT INTO Bookings (username, room_id, title, attendees, content, start_time, end_time, status, booking_type, weekdays) VALUES
	-- ONLY: Cuộc họp một lần
	('ntdu', 1, 'DKR1_Training 1 (Draft)', 'ntdu, pmhao, pnminh, bkkhanh, nhtien', 'Buổi đào tạo nội bộ', '2025-03-01 10:00:00', '2025-03-01 12:00:00', 'Cancelled', 'ONLY', NULL),
	('ntdu', 2, 'Finance Meeting', 'pmhao, bkkhanh', 'Thảo luận ngân sách', '2025-04-11 14:00:00', '2025-04-11 16:00:00', 'Confirmed', 'ONLY', NULL),
	('bkkhanh', 3, 'IT Strategy Session', 'bkkhanh, ntdu', 'Chiến lược IT năm 2025', '2025-03-03 09:00:00', '2025-03-03 11:00:00', 'Cancelled', 'ONLY', NULL),
	('pmhao', 1, 'Customer Feedback Session', 'pmhao, bkkhanh', 'Lắng nghe ý kiến khách hàng', '2025-04-20 15:00:00', '2025-04-20 16:00:00', 'Confirmed', 'ONLY', NULL),

	-- DAILY: Họp từ ngày 15/04/2025 đến 17/04/2025
	('ntdu', 1, 'Daily QA Sync', 'ntdu, htpham', 'Đồng bộ QA hàng ngày', '2025-04-15 10:30:00', '2025-04-15 11:00:00', 'Confirmed', 'DAILY', NULL),
	('ntdu', 1, 'Daily QA Sync', 'ntdu, htpham', 'Đồng bộ QA hàng ngày', '2025-04-16 10:30:00', '2025-04-16 11:00:00', 'Confirmed', 'DAILY', NULL),
	('ntdu', 1, 'Daily QA Sync', 'ntdu, htpham', 'Đồng bộ QA hàng ngày', '2025-04-17 10:30:00', '2025-04-17 11:00:00', 'Confirmed', 'DAILY', NULL),
	-- Daily từ ngày 06/03/2025 đến 08/03/2025
	('ntdu', 1, 'Daily Scrum Meeting', 'ntdu, pmhao, nhtien', 'Họp Scrum hằng ngày', '2025-03-06 09:00:00', '2025-03-06 09:30:00', 'Cancelled', 'DAILY', NULL),
	('ntdu', 1, 'Daily Scrum Meeting', 'ntdu, pmhao, nhtien', 'Họp Scrum hằng ngày', '2025-03-07 09:00:00', '2025-03-07 09:30:00', 'Cancelled', 'DAILY', NULL),
	('ntdu', 1, 'Daily Scrum Meeting', 'ntdu, pmhao, nhtien', 'Họp Scrum hằng ngày', '2025-03-08 09:00:00', '2025-03-08 09:30:00', 'Cancelled', 'DAILY', NULL),
	-- Daily từ ngày 11/04/2025 đến 12/04/2025
	('pmhao', 2, 'Daily Standup', 'pmhao, bkkhanh', 'Cập nhật công việc hằng ngày', '2025-04-11 09:00:00', '2025-04-11 09:30:00', 'Confirmed', 'DAILY', NULL),
	('pmhao', 2, 'Daily Standup', 'pmhao, bkkhanh', 'Cập nhật công việc hằng ngày', '2025-04-12 09:00:00', '2025-04-12 09:30:00', 'Confirmed', 'DAILY', NULL),

	-- Weekly từ ngày 11/04/2025 đến ngày 20/04/2025 (Fr, Mo, Tu, Fr) đặt ngày 11, 14, 15, 18
	('bkkhanh', 3, 'Weekly IT Sync', 'bkkhanh, ntdu', 'Đồng bộ công việc IT hằng tuần', '2025-04-11 10:00:00', '2025-04-11 11:00:00', 'Confirmed', 'WEEKLY', 'Mo,Tu,Fr'),
	('bkkhanh', 3, 'Weekly IT Sync', 'bkkhanh, ntdu', 'Đồng bộ công việc IT hằng tuần', '2025-04-14 10:00:00', '2025-04-14 11:00:00', 'Confirmed', 'WEEKLY', 'Mo,Tu,Fr'),
	('bkkhanh', 3, 'Weekly IT Sync', 'bkkhanh, ntdu', 'Đồng bộ công việc IT hằng tuần', '2025-04-15 10:00:00', '2025-04-15 11:00:00', 'Confirmed', 'WEEKLY', 'Mo,Tu,Fr'),
	('bkkhanh', 3, 'Weekly IT Sync', 'bkkhanh, ntdu', 'Đồng bộ công việc IT hằng tuần', '2025-04-18 10:00:00', '2025-04-18 11:00:00', 'Confirmed', 'WEEKLY', 'Mo,Tu,Fr'),
	-- Weekly từ ngày 01/03/2025 đến ngày 04/03/2025 (Mo, Tu) đặt ngày 03, 04
	('pnminh', 1, 'Weekly HR Meeting', 'nhtien, pmhao', 'Họp phòng nhân sự hằng tuần', '2025-03-03 14:00:00', '2025-03-03 15:00:00', 'Cancelled', 'WEEKLY', 'Mo,Tu'),
	('pnminh', 1, 'Weekly HR Meeting', 'nhtien, pmhao', 'Họp phòng nhân sự hằng tuần', '2025-03-04 14:00:00', '2025-03-04 15:00:00', 'Cancelled', 'WEEKLY', 'Mo,Tu'),
	-- Weekly từ ngày 11/04/2025 đến ngày 17/04/2025 (Fr, Mo, We, Th) đặt ngày 11, 14, 16, 17
	('htpham', 2, 'Engineering Weekly', 'htpham, ntdu', 'Cập nhật tiến độ kỹ thuật', '2025-04-11 08:30:00', '2025-04-11 09:30:00', 'Confirmed', 'WEEKLY', 'Mo,We,Th,Fr'),
	('htpham', 2, 'Engineering Weekly', 'htpham, ntdu', 'Cập nhật tiến độ kỹ thuật', '2025-04-14 08:30:00', '2025-04-14 09:30:00', 'Confirmed', 'WEEKLY', 'Mo,We,Th,Fr'),
	('htpham', 2, 'Engineering Weekly', 'htpham, ntdu', 'Cập nhật tiến độ kỹ thuật', '2025-04-16 08:30:00', '2025-04-16 09:30:00', 'Confirmed', 'WEEKLY', 'Mo,We,Th,Fr'),
	('htpham', 2, 'Engineering Weekly', 'htpham, ntdu', 'Cập nhật tiến độ kỹ thuật', '2025-04-17 08:30:00', '2025-04-17 09:30:00', 'Confirmed', 'WEEKLY', 'Mo,We,Th,Fr'),
	-- WEEKLY: Họp mỗi thứ Ba và thứ Năm từ ngày 22/04 đến 29/04
	('pnminh', 2, 'Dev Team Weekly', 'pnminh, nhtien', 'Lập kế hoạch sprint', '2025-04-22 14:00:00', '2025-04-22 15:00:00', 'Confirmed', 'WEEKLY', 'Tu,Th'),
	('pnminh', 2, 'Dev Team Weekly', 'pnminh, nhtien', 'Lập kế hoạch sprint', '2025-04-24 14:00:00', '2025-04-24 15:00:00', 'Confirmed', 'WEEKLY', 'Tu,Th'),
	('pnminh', 2, 'Dev Team Weekly', 'pnminh, nhtien', 'Lập kế hoạch sprint', '2025-04-29 14:00:00', '2025-04-29 15:00:00', 'Confirmed', 'WEEKLY', 'Tu,Th');
select * from requests;

select * from bookings;

