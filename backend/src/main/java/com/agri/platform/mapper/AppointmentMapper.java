package com.agri.platform.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.agri.platform.entity.Appointment;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/** 预约单 Mapper（统计类查询用注解 SQL） */
public interface AppointmentMapper extends BaseMapper<Appointment> {

    /**
     * 某项目某日某场次已占用人数（待支付 + 待使用）
     */
    @Select("SELECT IFNULL(SUM(people_count),0) FROM appointment "
            + "WHERE project_id=#{projectId} AND appoint_date=#{date} AND `session`=#{session} AND status IN (0,1)")
    int sumBooked(@Param("projectId") Long projectId, @Param("date") LocalDate date, @Param("session") String session);

    /**
     * 商家预约单分页（通过 farm 归属过滤，数据隔离）
     */
    @Select("<script>SELECT a.* FROM appointment a JOIN farm f ON a.farm_id=f.id "
            + "WHERE f.merchant_id=#{merchantId} "
            + "<if test='status!=null'> AND a.status=#{status}</if> "
            + "<if test='date!=null'> AND a.appoint_date=#{date}</if> "
            + "ORDER BY a.create_time DESC</script>")
    IPage<Appointment> selectMerchantPage(Page<Appointment> page, @Param("merchantId") Long merchantId,
                                          @Param("status") Integer status, @Param("date") LocalDate date);

    /**
     * 商家未读预约通知数（已支付且 merchant_read=0）
     */
    @Select("SELECT COUNT(*) FROM appointment a JOIN farm f ON a.farm_id=f.id "
            + "WHERE f.merchant_id=#{merchantId} AND a.merchant_read=0 AND a.status IN (1,2)")
    int countUnread(@Param("merchantId") Long merchantId);

    /**
     * 商家预约人次（已支付）
     */
    @Select("SELECT IFNULL(SUM(a.people_count),0) FROM appointment a JOIN farm f ON a.farm_id=f.id "
            + "WHERE f.merchant_id=#{merchantId} AND a.status IN (1,2)")
    int sumMerchantPeople(@Param("merchantId") Long merchantId);

    /**
     * 近 7 日预约量序列
     */
    @Select("SELECT DATE_FORMAT(create_time,'%Y-%m-%d') d, COUNT(*) c FROM appointment "
            + "WHERE create_time>=#{start} GROUP BY d")
    List<Map<String, Object>> countByDay(@Param("start") LocalDateTime start);

    /**
     * 商家近 7 日预约人次趋势（已支付口径，按创建日期）
     */
    @Select("SELECT DATE_FORMAT(a.create_time,'%Y-%m-%d') d, IFNULL(SUM(a.people_count),0) c "
            + "FROM appointment a JOIN farm f ON a.farm_id=f.id "
            + "WHERE f.merchant_id=#{merchantId} AND a.status IN (1,2) AND a.create_time>=#{start} GROUP BY d")
    List<Map<String, Object>> merchantTrend(@Param("merchantId") Long merchantId,
                                            @Param("start") LocalDateTime start);
}
