-- Script cập nhật domain từ goivondautu.delitech.vn sang goivonkhoinghiep.vn
-- Chạy script này trong database để cập nhật site_url

-- Cập nhật site_url trong bảng Wo_Config
UPDATE `Wo_Config` SET `value` = 'https://goivonkhoinghiep.vn' WHERE `name` = 'site_url';

-- Kiểm tra kết quả
SELECT `name`, `value` FROM `Wo_Config` WHERE `name` = 'site_url';

