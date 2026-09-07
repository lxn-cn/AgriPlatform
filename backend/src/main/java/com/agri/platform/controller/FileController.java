package com.agri.platform.controller;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import javax.imageio.ImageIO;
import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;

/**
 * 占位图服务：按 seed 动态生成纯色 + 文字 PNG，演示环境无需图片资源。
 * 访问示例：/api/file/placeholder/p1.png、farm3.png、banner1.png
 */
@RestController
public class FileController {

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
}
