package com.agri.platform.controller;

import com.agri.platform.common.Result;
import com.agri.platform.entity.Address;
import com.agri.platform.service.AddressService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;
import java.util.List;

/**
 * 收货地址接口
 */
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/addresses")
public class AddressController {

    private final AddressService addressService;

    /** 地址列表（默认地址置顶） */
    @GetMapping
    public Result<List<Address>> list() {
        return Result.ok(addressService.list());
    }

    /** 新增地址（省市默认天津市） */
    @PostMapping
    public Result<Address> create(@Valid @RequestBody Address address) {
        return Result.ok(addressService.create(address));
    }

    /** 修改地址 */
    @PutMapping("/{id}")
    public Result<Address> update(@PathVariable Long id, @Valid @RequestBody Address address) {
        return Result.ok(addressService.update(id, address));
    }

    /** 删除地址 */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        addressService.delete(id);
        return Result.ok("已删除", null);
    }

    /** 设为默认地址 */
    @PostMapping("/{id}/default")
    public Result<Void> setDefault(@PathVariable Long id) {
        addressService.setDefault(id);
        return Result.ok("已设为默认地址", null);
    }
}
