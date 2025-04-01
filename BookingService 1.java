package com.example.hrms.biz.booking.service;

import com.example.hrms.biz.booking.model.Booking;
import com.example.hrms.biz.booking.model.criteria.BookingCriteria;
import com.example.hrms.biz.booking.model.dto.BookingDTO;
import com.example.hrms.biz.booking.repository.BookingMapper;
import com.example.hrms.utils.DateUtils;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import com.example.hrms.enumation.BookingType;

@Service
public class BookingService {
    private final BookingMapper bookingMapper;

    public BookingService(BookingMapper bookingMapper) {
        this.bookingMapper = bookingMapper;
    }

    public Booking getBookingById(Long bookingId) {
        return bookingMapper.selectById(bookingId);
    }

    public void insert(BookingDTO.Req req) {
        List<Booking> booking = handleBookingType(req);

        if (!booking.isEmpty()) {
            bookingMapper.insert(req.toBooking());
        }
    }

    public void updateBooking(Booking req) {
        List<Booking> booking = handleBookingType(BookingDTO.Req.fromBooking(req));
        if (!booking.isEmpty()) {
            bookingMapper.updateBooking(req);
        }
    }

    public void deleteBooking(Long bookingId) {
        bookingMapper.deleteBooking(bookingId);
    }

    public boolean isConflict(Booking booking) {
        List<Booking> conflictingBookings = bookingMapper.findConflictingBookings(
                booking.getRoomId(), booking.getStartTime(), booking.getEndTime()
        );
        return !conflictingBookings.isEmpty();
    }

    public int count(BookingCriteria criteria) {
        return bookingMapper.count(criteria);
    }

    public List<BookingDTO.Resp> list(BookingCriteria criteria) {
        List<Booking> bookings = bookingMapper.select(criteria);
        return bookings.stream().map(BookingDTO.Resp::toResponse).toList();
    }

    public List<BookingDTO.Resp> getAllBookings() {
        List<Booking> bookings = bookingMapper.selectAll();
        return bookings.stream().map(BookingDTO.Resp::toResponse).toList();
    }

    private List<Booking> handleBookingType(BookingDTO.Req req) {
        List<Booking> bookings = new ArrayList<>();
        LocalDateTime startTime = DateUtils.parseDateTime(req.getStartDate() + " " + req.getStartTime());
        LocalDateTime endTime = DateUtils.parseDateTime(req.getEndDate() + " " + req.getEndTime());

        switch (req.getBookingType()) {
            case "ONLY":
                Booking booking = req.toBooking();
                booking.setBookingType(BookingType.ONLY);
                booking.setStartTime(startTime);
                booking.setEndTime(endTime);
                booking.setWeekdays(null);
                bookings.add(booking);
                break;
            case "DAILY":
                long elapseTime = ChronoUnit.DAYS.between(startTime, endTime);
                for (int i = 0; i < elapseTime; i++) {
                    LocalDateTime startTimeToday = startTime.plusDays(i);
                    LocalDateTime endTimeToday = startTimeToday.withHour(endTime.getHour()).withMinute(endTime.getMinute());
                    Booking dailyBooking = req.toBooking();
                    dailyBooking.setBookingType(BookingType.DAILY);
                    dailyBooking.setStartTime(startTimeToday);
                    dailyBooking.setEndTime(endTimeToday);
                    dailyBooking.setWeekdays(null);
                    bookings.add(dailyBooking);
                }
                break;
            case "WEEKLY":
                long elapseTime1 = ChronoUnit.WEEKS.between(startTime, endTime);
                List<String> weekdays = req.getWeekdays();
                if (weekdays == null || weekdays.isEmpty()) {
                    weekdays = Arrays.asList("mo", "tu", "we", "th", "fr");
                }
                for (int i = 0; i < elapseTime1; i++) {
                    LocalDateTime startTimeToday = startTime.plusWeeks(i);
                    LocalDateTime endTimeToday = startTimeToday.withHour(endTime.getHour()).withMinute(endTime.getMinute());
                    Booking weeklyBooking = req.toBooking();
                    weeklyBooking.setBookingType(BookingType.WEEKLY);
                    weeklyBooking.setStartTime(startTimeToday);
                    weeklyBooking.setEndTime(endTimeToday);
                    weeklyBooking.setWeekdays(String.join(", ", weekdays));
                    bookings.add(weeklyBooking);
                }
                break;
            default:
                throw new IllegalArgumentException("Invalid booking type");
        }
        return bookings;
    }
}
