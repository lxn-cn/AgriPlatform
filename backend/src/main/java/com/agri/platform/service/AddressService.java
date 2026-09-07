package com.agri.platform.service;

import com.agri.platform.common.BizException;
import com.agri.platform.entity.Address;
import com.agri.platform.mapper.AddressMapper;
import com.agri.platform.util.AuthContext;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 收货地址服务：增删改查 + 默认地址切换（省市默认天津市）
 */
@Service
@RequiredArgsConstructor
public class AddressService {

    private final AddressMapper addressMapper;

    /** 地址列表（默认地址置顶） */
    public List<Address> list() {
        return addressMapper.selectList(new LambdaQueryWrapper<Address>()
                .eq(Address::getUserId, AuthContext.userId())
                .orderByDesc(Address::getIsDefault)
                .orderByDesc(Address::getId));
    }

    /** 新增地址 */
    @Transactional(rollbackFor = Exception.class)
    public Address create(Address input) {
        Long userId = AuthContext.userId();
        validate(input);
        Address address = new Address();
        copyInput(address, input);
        address.setUserId(userId);
        address.setProvince("天津市");
        address.setCity("天津市");
        address.setIsDefault(Integer.valueOf(1).equals(input.getIsDefault()) ? 1 : 0);
        address.setCreateTime(LocalDateTime.now());
        address.setUpdateTime(LocalDateTime.now());
        if (address.getIsDefault() == 1) {
            clearDefault(userId, null);
        }
        addressMapper.insert(address);
        return address;
    }

    /** 修改地址 */
    @Transactional(rollbackFor = Exception.class)
    public Address update(Long id, Address input) {
        Address address = ownedOrThrow(id);
        validate(input);
        copyInput(address, input);
        if (Integer.valueOf(1).equals(input.getIsDefault())) {
            clearDefault(address.getUserId(), id);
            address.setIsDefault(1);
        }
        address.setUpdateTime(LocalDateTime.now());
        addressMapper.updateById(address);
        return address;
    }

    /** 删除地址 */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        Address address = ownedOrThrow(id);
        addressMapper.deleteById(address.getId());
    }

    /** 设为默认地址 */
    @Transactional(rollbackFor = Exception.class)
    public void setDefault(Long id) {
        Address address = ownedOrThrow(id);
        clearDefault(address.getUserId(), id);
        address.setIsDefault(1);
        address.setUpdateTime(LocalDateTime.now());
        addressMapper.updateById(address);
    }

    private void clearDefault(Long userId, Long excludeId) {
        List<Address> list = addressMapper.selectList(new LambdaQueryWrapper<Address>()
                .eq(Address::getUserId, userId)
                .eq(Address::getIsDefault, 1));
        for (Address a : list) {
            if (excludeId != null && excludeId.equals(a.getId())) {
                continue;
            }
            a.setIsDefault(0);
            a.setUpdateTime(LocalDateTime.now());
            addressMapper.updateById(a);
        }
    }

    private void validate(Address input) {
        if (!StringUtils.hasText(input.getReceiver())) {
            throw new BizException("请填写收货人姓名");
        }
        if (!StringUtils.hasText(input.getPhone())) {
            throw new BizException("请填写联系电话");
        }
        if (!StringUtils.hasText(input.getDistrict())) {
            throw new BizException("请填写所在区县");
        }
        if (!StringUtils.hasText(input.getDetail())) {
            throw new BizException("请填写详细地址");
        }
    }

    private void copyInput(Address target, Address input) {
        target.setReceiver(input.getReceiver().trim());
        target.setPhone(input.getPhone().trim());
        target.setDistrict(input.getDistrict().trim());
        target.setDetail(input.getDetail().trim());
    }

    private Address ownedOrThrow(Long id) {
        Address address = addressMapper.selectById(id);
        if (address == null || !address.getUserId().equals(AuthContext.userId())) {
            throw new BizException("收货地址不存在");
        }
        return address;
    }
}
