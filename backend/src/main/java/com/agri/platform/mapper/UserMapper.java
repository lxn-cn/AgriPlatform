package com.agri.platform.mapper;

import com.agri.platform.entity.User;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/** 用户 Mapper */
public interface UserMapper extends BaseMapper<User> {

    /**
     * 按天统计新增用户数（近 7 日趋势用，与 OrderMapper.countByDay 同套路）
     */
    @Select("SELECT DATE_FORMAT(create_time,'%Y-%m-%d') d, COUNT(*) c FROM user "
            + "WHERE create_time>=#{start} GROUP BY d")
    List<Map<String, Object>> countByDay(@Param("start") LocalDateTime start);
}
