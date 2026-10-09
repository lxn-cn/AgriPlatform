package com.agri.platform.controller;

import com.agri.platform.common.BizException;
import com.agri.platform.common.Constants;
import com.agri.platform.common.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

/**
 * 文件服务：占位图生成 + 本地图片上传。
 * 上传文件落盘到工作目录 upload/ 下，数据库只存相对路径（/upload/xxx.jpg）。
 */
@RestController
public class FileController {

    /** 允许上传的图片扩展名白名单 */
    private static final List<String> ALLOWED_EXT = Arrays.asList("jpg", "jpeg", "png", "webp", "gif");

    /** 单文件大小上限 5MB */
    private static final long MAX_SIZE = 5L * 1024 * 1024;

    /** 本地上传目录（application.yml app.upload-dir，相对路径基于工作目录） */
    @Value("${app.upload-dir:upload}")
    private String uploadDir;


    /** 配色（底色、文字色），按 seed 哈希轮换 */
    private static final Color[][] PALETTE = {
            {new Color(46, 158, 107), Color.WHITE},   // 绿
            {new Color(74, 144, 226), Color.WHITE},   // 蓝
            {new Color(230, 162, 60), Color.WHITE},   // 橙
            {new Color(155, 89, 182), Color.WHITE},   // 紫
            {new Color(69, 176, 175), Color.WHITE},   // 青
            {new Color(214, 92, 92), Color.WHITE},    // 红
            {new Color(52, 73, 94), Color.WHITE},     // 深灰蓝
            {new Color(39, 174, 96), Color.WHITE},    // 草绿
    };

    /** 生成 640x400 占位图 PNG */
    @GetMapping(value = "/api/file/placeholder/{seed}.png", produces = MediaType.IMAGE_PNG_VALUE)
    public byte[] placeholder(@PathVariable String seed) throws Exception {
        int width = 640;
        int height = 400;
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        try {
            g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
            Color[] pair = PALETTE[Math.floorMod(seed.hashCode(), PALETTE.length)];
            g.setColor(pair[0]);
            g.fillRect(0, 0, width, height);
            // 半透明装饰圆
            g.setColor(new Color(255, 255, 255, 30));
            g.fillOval(-80, height - 220, 360, 360);
            g.fillOval(width - 220, -100, 340, 340);
            // 文字：seed + 尺寸
            g.setColor(pair[1]);
            String text = seed.length() > 20 ? seed.substring(0, 20) : seed;
            Font font = new Font(Font.SANS_SERIF, Font.BOLD, 56);
            g.setFont(font);
            FontMetrics metrics = g.getFontMetrics();
            int x = (width - metrics.stringWidth(text)) / 2;
            int y = height / 2;
            g.drawString(text, x, y);
            g.setFont(new Font(Font.SANS_SERIF, Font.PLAIN, 22));
            String sub = width + " × " + height;
            FontMetrics subMetrics = g.getFontMetrics();
            g.drawString(sub, (width - subMetrics.stringWidth(sub)) / 2, y + 44);
        } finally {
            g.dispose();
        }
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(image, "png", out);
        return out.toByteArray();
    }

    /**
     * 图片上传：UUID 重命名后落盘到本地 upload/ 目录，返回相对路径（/upload/xxx.jpg）。
     * 注意：该路径在 JWT 拦截器中属"可选登录"，此处必须自校验角色。
     */
    @PostMapping("/api/file/upload")
    public Result<Map<String, Object>> upload(@RequestParam("file") MultipartFile file,
                                              HttpServletRequest request) {
        Object role = request.getAttribute(Constants.ATTR_ROLE);
        if (!Constants.ROLE_USER.equals(role) && !Constants.ROLE_MERCHANT.equals(role)
                && !Constants.ROLE_ADMIN.equals(role) && !Constants.ROLE_SUPER.equals(role)) {
            return Result.fail(401, "请先登录");
        }
        if (file == null || file.isEmpty()) {
            throw new BizException("上传文件不能为空");
        }
        String original = file.getOriginalFilename();
        int dot = original == null ? -1 : original.lastIndexOf('.');
        String ext = dot >= 0 && dot < original.length() - 1
                ? original.substring(dot + 1).toLowerCase(Locale.ROOT) : "";
        if (!ALLOWED_EXT.contains(ext)) {
            throw new BizException("仅支持 jpg/jpeg/png/webp/gif 格式图片");
        }
        if (file.getSize() > MAX_SIZE) {
            throw new BizException("图片大小不能超过 5MB");
        }
        try {
            Path dir = Paths.get(uploadDir).toAbsolutePath().normalize();
            Files.createDirectories(dir);
            // 文件名完全由服务端生成（UUID + 白名单扩展名），天然防路径穿越
            String fileName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            file.transferTo(dir.resolve(fileName));
            Map<String, Object> data = new LinkedHashMap<String, Object>();
            data.put("url", "/upload/" + fileName);
            return Result.ok(data);
        } catch (IOException e) {
            throw new BizException("图片保存失败，请稍后重试");
        }
    }
}
