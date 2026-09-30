--------------------------------------------------------------------------------
-- SCRIPT TỔNG HỢP HỆ THỐNG QUẢN LÝ NHÀ SÁCH (ĐỒNG BỘ HOÀN CHỈNH)
--------------------------------------------------------------------------------

-- 1. TẠO CƠ SỞ DỮ LIỆU & KIỂM TRA TỒN TẠI
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'QuanLyNhaSach')
BEGIN
    CREATE DATABASE QuanLyNhaSach;
END
GO

USE QuanLyNhaSach;
GO

-- Xóa các bảng cũ theo thứ tự phụ thuộc khóa ngoại để tránh lỗi khi chạy lại script
IF OBJECT_ID('ChiTietHoaDon', 'U') IS NOT NULL DROP TABLE ChiTietHoaDon;
IF OBJECT_ID('HoaDon', 'U') IS NOT NULL DROP TABLE HoaDon;
IF OBJECT_ID('PhieuNhap', 'U') IS NOT NULL DROP TABLE PhieuNhap;
IF OBJECT_ID('Sach', 'U') IS NOT NULL DROP TABLE Sach;
IF OBJECT_ID('KhachHang', 'U') IS NOT NULL DROP TABLE KhachHang;
IF OBJECT_ID('NhanVien', 'U') IS NOT NULL DROP TABLE NhanVien;
IF OBJECT_ID('NXB', 'U') IS NOT NULL DROP TABLE NXB;
IF OBJECT_ID('TacGia', 'U') IS NOT NULL DROP TABLE TacGia;
IF OBJECT_ID('TheLoai', 'U') IS NOT NULL DROP TABLE TheLoai;
GO

--------------------------------------------------------------------------------
-- 2. TẠO CẤU TRÚC CÁC BẢNG (SCHEMA)
--------------------------------------------------------------------------------

-- Bảng 1: Thể loại
CREATE TABLE TheLoai (
    MaTheLoai INT IDENTITY(1,1) PRIMARY KEY,
    TenTheLoai NVARCHAR(100) NOT NULL
);

-- Bảng 2: Tác giả
CREATE TABLE TacGia (
    MaTacGia INT IDENTITY(1,1) PRIMARY KEY,
    TenTacGia NVARCHAR(100) NOT NULL,
    TieuSu NVARCHAR(MAX)
);

-- Bảng 3: Nhà xuất bản
CREATE TABLE NXB (
    MaNXB INT IDENTITY(1,1) PRIMARY KEY,
    TenNXB NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(255)
);

-- Bảng 4: Nhân viên
CREATE TABLE NhanVien (
    MaNhanVien INT IDENTITY(1,1) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    DienThoai VARCHAR(15),
    ChucVu NVARCHAR(50)
);

-- Bảng 5: Khách hàng
CREATE TABLE KhachHang (
    MaKhachHang INT IDENTITY(1,1) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    DienThoai VARCHAR(15),
    DiaChi NVARCHAR(255)
);

-- Bảng 6: Sách (Quản lý kho sách)
CREATE TABLE Sach (
    MaSach INT IDENTITY(1,1) PRIMARY KEY,
    TenSach NVARCHAR(200) NOT NULL,
    MaTheLoai INT,
    MaTacGia INT,
    MaNXB INT,
    GiaBan DECIMAL(18, 2) NOT NULL,
    SoLuongTon INT NOT NULL CHECK (SoLuongTon >= 0) DEFAULT 0,
    FOREIGN KEY (MaTheLoai) REFERENCES TheLoai(MaTheLoai),
    FOREIGN KEY (MaTacGia) REFERENCES TacGia(MaTacGia),
    FOREIGN KEY (MaNXB) REFERENCES NXB(MaNXB)
);

-- Bảng 7: Phiếu nhập kho
CREATE TABLE PhieuNhap (
    MaPhieuNhap INT IDENTITY(1,1) PRIMARY KEY,
    MaNhanVien INT,
    NgayNhap DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
);

-- Bảng 8: Hóa đơn bán hàng
CREATE TABLE HoaDon (
    MaHoaDon INT IDENTITY(1,1) PRIMARY KEY,
    MaNhanVien INT,
    MaKhachHang INT,
    NgayLap DATETIME DEFAULT GETDATE(),
    TrangThai NVARCHAR(50) DEFAULT N'Hoàn thành',
    TongTien DECIMAL(18, 2) DEFAULT 0,
    FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien),
    FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang)
);

-- Bảng 9: Chi tiết hóa đơn
CREATE TABLE ChiTietHoaDon (
    MaHoaDon INT,
    MaSach INT,
    SoLuongMua INT NOT NULL CHECK (SoLuongMua > 0),
    DonGia DECIMAL(18, 2) NOT NULL,
    PhanTramGiamGia DECIMAL(5,2) DEFAULT 0,
    ThanhTien AS (SoLuongMua * DonGia * (1 - PhanTramGiamGia / 100)) PERSISTED,
    PRIMARY KEY (MaHoaDon, MaSach),
    FOREIGN KEY (MaHoaDon) REFERENCES HoaDon(MaHoaDon),
    FOREIGN KEY (MaSach) REFERENCES Sach(MaSach)
);
GO

--------------------------------------------------------------------------------
-- 3. TẠO TRIGGER TỰ ĐỘNG CẬP NHẬT TỒN KHO KHI BÁN HÀNG
--------------------------------------------------------------------------------
CREATE TRIGGER trg_CapNhatTonKho
ON ChiTietHoaDon
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Tự động trừ số lượng tồn kho dựa vào dữ liệu vừa bán trong bảng 'inserted'
    UPDATE Sach
    SET SoLuongTon = Sach.SoLuongTon - inserted.SoLuongMua
    FROM Sach
    INNER JOIN inserted ON Sach.MaSach = inserted.MaSach;
END;
GO

--------------------------------------------------------------------------------
-- 4. TẠO STORED PROCEDURE XỬ LÝ GIAO DỊCH BÁN HÀNG AN TOÀN
--------------------------------------------------------------------------------
CREATE PROCEDURE sp_BanHang
    @MaHoaDon INT,
    @MaSach INT,
    @SoLuongMua INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TonKhoHienTai INT;
    SELECT @TonKhoHienTai = SoLuongTon FROM Sach WHERE MaSach = @MaSach;

    -- Kiểm tra 1: Sách có tồn tại không?
    IF @TonKhoHienTai IS NULL
    BEGIN
        PRINT N'Lỗi: Sách không tồn tại trong hệ thống!';
        RETURN;
    END

    -- Kiểm tra 2: Kho có đủ sách để bán không?
    IF @TonKhoHienTai < @SoLuongMua
    BEGIN
        PRINT N'Không đủ hàng! Kho hiện tại chỉ còn: ' + CAST(@TonKhoHienTai AS VARCHAR) + N', không thể thực hiện giao dịch.';
        RETURN; 
    END

    -- Tiến hành giao dịch an toàn (Transaction)
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @GiaBan DECIMAL(18,2);
        SELECT @GiaBan = GiaBan FROM Sach WHERE MaSach = @MaSach;

        -- Thêm chi tiết hóa đơn (Trigger trg_CapNhatTonKho sẽ tự động trừ kho)
        INSERT INTO ChiTietHoaDon (MaHoaDon, MaSach, SoLuongMua, DonGia)
        VALUES (@MaHoaDon, @MaSach, @SoLuongMua, @GiaBan);

        COMMIT TRANSACTION;
        PRINT N'Giao dịch bán sách thành công!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

--------------------------------------------------------------------------------
-- 5. CHÈN DỮ LIỆU MẪU (BỔ SUNG ÍT NHẤT 3 INSERT CHO MỖI BẢNG)
--------------------------------------------------------------------------------

-- 5.1. Thể loại (Ít nhất 3 dòng)
INSERT INTO TheLoai (TenTheLoai) VALUES 
(N'Văn học trong nước'), 
(N'Văn học nước ngoài'), 
(N'Kinh tế - Quản lý'), 
(N'Tâm lý - Kỹ năng sống'),
(N'Sách thiếu nhi');

-- 5.2. Tác giả (Ít nhất 3 dòng)
INSERT INTO TacGia (TenTacGia, TieuSu) VALUES 
(N'Nguyễn Nhật Ánh', N'Nhà văn nổi tiếng chuyên viết cho thanh thiếu niên.'),
(N'Haruki Murakami', N'Tiểu thuyết gia người Nhật Bản nổi tiếng thế giới.'),
(N'Dale Carnegie', N'Chuyên gia phát triển bản thân và kỹ năng giao tiếp.'),
(N'Paulo Coelho', N'Nhà văn người Brazil, nổi tiếng với tác phẩm Nhà Giả Kim.');

-- 5.3. Nhà xuất bản (Ít nhất 3 dòng)
INSERT INTO NXB (TenNXB, DiaChi) VALUES 
(N'NXB Trẻ', N'161B Lý Chính Thắng, Q.3, TP.HCM'),
(N'NXB Hội Nhà Văn', N'65 Nguyễn Du, Hai Bà Trưng, Hà Nội'),
(N'NXB Kim Đồng', N'55 Quang Trung, Hai Bà Trưng, Hà Nội'),
(N'NXB Tổng hợp TP.HCM', N'62 Nguyễn Thị Minh Khai, Q.1, TP.HCM');

-- 5.4. Nhân viên (Ít nhất 3 dòng)
INSERT INTO NhanVien (HoTen, DienThoai, ChucVu) VALUES 
(N'Nguyễn Văn Trưởng', '0901112223', N'Quản lý cửa hàng'),
(N'Trần Thị Thu', '0904445566', N'Nhân viên bán hàng'),
(N'Lê Hoàng Nam', '0988776655', N'Nhân viên kho'),
(N'Phạm Thị Mai', '0912345678', N'Thu ngân');

-- 5.5. Khách hàng (Ít nhất 3 dòng)
INSERT INTO KhachHang (HoTen, DienThoai, DiaChi) VALUES 
(N'Nguyễn Văn An', '0903123456', N'Quận 1, TP.HCM'),
(N'Trần Thị Bích', '0918234567', N'Quận 3, TP.HCM'),
(N'Lê Hoàng Cường', '0987345678', N'Quận 5, TP.HCM'),
(N'Đỗ Thị Em', '0975567890', N'Quận Tân Bình, TP.HCM');

-- 5.6. Sách (Ít nhất 3 dòng)
INSERT INTO Sach (TenSach, MaTheLoai, MaTacGia, MaNXB, GiaBan, SoLuongTon) VALUES 
(N'Mắt Biếc', 1, 1, 1, 110000, 15),       -- MaSach = 1
(N'Rừng Na Uy', 2, 2, 2, 140000, 10),      -- MaSach = 2
(N'Đắc Nhân Tâm', 4, 3, 3, 86000, 20),      -- MaSach = 3
(N'Nhà Giả Kim', 2, 4, 4, 79000, 25);      -- MaSach = 4

-- 5.7. Phiếu nhập (Ít nhất 3 dòng)
INSERT INTO PhieuNhap (MaNhanVien, NgayNhap) VALUES 
(1, '2026-01-10 08:00:00'),
(3, '2026-02-15 09:30:00'),
(1, '2026-03-01 10:00:00'),
(3, '2026-03-10 14:00:00');

-- 5.8. Hóa đơn (Ít nhất 3 dòng)
INSERT INTO HoaDon (MaNhanVien, MaKhachHang, NgayLap, TrangThai) VALUES 
(2, 1, '2026-03-02 09:15:00', N'Hoàn thành'), -- MaHoaDon = 1
(2, 2, '2026-03-03 10:30:00', N'Hoàn thành'), -- MaHoaDon = 2
(4, 3, '2026-03-04 14:20:00', N'Hoàn thành'), -- MaHoaDon = 3
(2, 4, '2026-03-05 16:45:00', N'Đang xử lý'); -- MaHoaDon = 4

-- 5.9. Chi tiết hóa đơn (Ít nhất 3 dòng)
INSERT INTO ChiTietHoaDon (MaHoaDon, MaSach, SoLuongMua, DonGia, PhanTramGiamGia) VALUES 
(1, 1, 2, 110000, 0),  -- Hóa đơn 1 mua 2 cuốn Mắt Biếc
(1, 3, 1, 86000, 10),  -- Hóa đơn 1 mua 1 cuốn Đắc Nhân Tâm (giảm 10%)
(2, 2, 1, 140000, 0),  -- Hóa đơn 2 mua 1 cuốn Rừng Na Uy
(3, 4, 2, 79000, 5),   -- Hóa đơn 3 mua 2 cuốn Nhà Giả Kim (giảm 5%)
(4, 1, 1, 110000, 0);  -- Hóa đơn 4 mua 1 cuốn Mắt Biếc
GO

-- 5.10. Cập nhật tổng tiền cho các hóa đơn dựa trên chi tiết
UPDATE h
SET h.TongTien = c.TongCong
FROM HoaDon h
INNER JOIN (
    SELECT MaHoaDon, SUM(ThanhTien) AS TongCong
    FROM ChiTietHoaDon
    GROUP BY MaHoaDon
) c ON h.MaHoaDon = c.MaHoaDon;
GO

--------------------------------------------------------------------------------
-- 6. KIỂM TRA VÀ TEST THỰC TẾ
--------------------------------------------------------------------------------

-- Kiểm tra danh sách sách và số lượng tồn kho trước khi bán
SELECT * FROM Sach;

-- Test thử thủ tục bán hàng (Mua 3 cuốn Mắt Biếc - MaSach = 1 vào HoaDon = 4)
EXEC sp_BanHang @MaHoaDon = 4, @MaSach = 1, @SoLuongMua = 3;

-- Kiểm tra lại tồn kho sau giao dịch (Mắt Biếc sẽ bị trừ tự động)
SELECT * FROM Sach;

-- Xem báo cáo chi tiết hóa đơn
SELECT 
    h.MaHoaDon,
    h.NgayLap,
    kh.HoTen AS TenKhachHang,
    nv.HoTen AS NhanVienLap,
    s.TenSach,
    ct.SoLuongMua,
    ct.DonGia,
    ct.PhanTramGiamGia,
    ct.ThanhTien
FROM HoaDon h
JOIN KhachHang kh ON h.MaKhachHang = kh.MaKhachHang
JOIN NhanVien nv ON h.MaNhanVien = nv.MaNhanVien
JOIN ChiTietHoaDon ct ON h.MaHoaDon = ct.MaHoaDon
JOIN Sach s ON ct.MaSach = s.MaSach;