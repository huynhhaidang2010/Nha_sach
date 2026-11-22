-- Tạo cơ sở dữ liệu
CREATE DATABASE NhaSachMinhKhai;
GO
USE NhaSachMinhKhai;
GO

-- Xoá bảng theo thứ tự ngược lại để tránh lỗi khóa ngoại
DROP TABLE IF EXISTS ChiTietDonHang;
DROP TABLE IF EXISTS ChiTietGioHang;
DROP TABLE IF EXISTS ChiTietPhieuNhap;
DROP TABLE IF EXISTS DanhGia;
DROP TABLE IF EXISTS DonHang;
DROP TABLE IF EXISTS PhieuNhapKho;
DROP TABLE IF EXISTS GioHang;
DROP TABLE IF EXISTS Sach;
DROP TABLE IF EXISTS KhuyenMai;
DROP TABLE IF EXISTS NhaCungCap;
DROP TABLE IF EXISTS NguoiDung;
DROP TABLE IF EXISTS NhaXuatBan;
DROP TABLE IF EXISTS DanhMuc;
DROP TABLE IF EXISTS TacGia;
GO

-- 1. Bảng Tác Giả
CREATE TABLE TacGia (
    MaTG VARCHAR(10) PRIMARY KEY,
    TenTG NVARCHAR(100) NOT NULL,
    TieuSu NVARCHAR(MAX)
);
GO

-- 2. Bảng Danh Mục
CREATE TABLE DanhMuc (
    MaDM VARCHAR(10) PRIMARY KEY,
    TenDM NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(255)
);
GO

-- 3. Bảng Nhà Xuất Bản
CREATE TABLE NhaXuatBan (
    MaNXB VARCHAR(10) PRIMARY KEY,
    TenNXB NVARCHAR(150) NOT NULL,
    Diachi NVARCHAR(255)
);
GO

-- 4. Bảng Người Dùng
CREATE TABLE NguoiDung (
    MaND VARCHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    SDT VARCHAR(15),
    MatKhau VARCHAR(255) NOT NULL,
    VaiTro NVARCHAR(20),
    NgayTao DATETIME DEFAULT GETDATE(),
    Active BIT DEFAULT 1
);
GO

-- 5. Bảng Nhà Cung Cấp
CREATE TABLE NhaCungCap (
    MaNCC VARCHAR(10) PRIMARY KEY,
    TenNCC NVARCHAR(150) NOT NULL,
    DiaChi NVARCHAR(255),
    SDT VARCHAR(15),
    Email VARCHAR(100)
);
GO

-- 6. Bảng Khuyến Mãi
CREATE TABLE KhuyenMai (
    MaKM VARCHAR(10) PRIMARY KEY,
    TenKM NVARCHAR(100) NOT NULL,
    PhanTramGiam INT,
    NgayBatDau DATE,
    NgayKetThuc DATE,
    MoTa NVARCHAR(255)
);
GO

-- 7. Bảng Sách
CREATE TABLE Sach (
    MaSach VARCHAR(10) PRIMARY KEY,
    MaTG VARCHAR(10),
    MaDM VARCHAR(10),
    MaNXB VARCHAR(10),
    TenSach NVARCHAR(200) NOT NULL,
    SoLuongTon INT DEFAULT 0,
    GiaBan DECIMAL(18,2) NOT NULL,
    HinhAnh VARCHAR(255),
    MoTa NVARCHAR(MAX),
    FOREIGN KEY (MaTG) REFERENCES TacGia(MaTG),
    FOREIGN KEY (MaDM) REFERENCES DanhMuc(MaDM),
    FOREIGN KEY (MaNXB) REFERENCES NhaXuatBan(MaNXB)
);
GO

-- 8. Bảng Giỏ Hàng
CREATE TABLE GioHang (
    MaGioHang VARCHAR(10) PRIMARY KEY,
    MaND VARCHAR(10),
    NgayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaND) REFERENCES NguoiDung(MaND)
);
GO

-- 9. Bảng Chi Tiết Giỏ Hàng
CREATE TABLE ChiTietGioHang (
    MaGioHang VARCHAR(10),
    MaSach VARCHAR(10),
    SoLuong INT NOT NULL,
    FOREIGN KEY (MaGioHang) REFERENCES GioHang(MaGioHang),
    FOREIGN KEY (MaSach) REFERENCES Sach(MaSach)
);
GO

-- 10. Bảng Đơn Hàng
CREATE TABLE DonHang (
    MaDH VARCHAR(10) PRIMARY KEY,
    MaKM VARCHAR(10),
    MaND VARCHAR(10),
    TTTT INT,
    TTDH INT,
    NgayDat DATETIME DEFAULT GETDATE(),
    TongTien DECIMAL(18,2),
    DiaChiGiaoHang NVARCHAR(255),
    PhuongThucTT NVARCHAR(50),
    FOREIGN KEY (MaKM) REFERENCES KhuyenMai(MaKM),
    FOREIGN KEY (MaND) REFERENCES NguoiDung(MaND)
);
GO

-- 11. Bảng Chi Tiết Đơn Hàng
CREATE TABLE ChiTietDonHang (
    MaSach VARCHAR(10),
    MaDH VARCHAR(10),
    SoLuong INT NOT NULL,
    DonGia DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (MaSach) REFERENCES Sach(MaSach),
    FOREIGN KEY (MaDH) REFERENCES DonHang(MaDH)
);
GO

-- 12. Bảng Phiếu Nhập Kho
CREATE TABLE PhieuNhapKho (
    MaPhieuNhap VARCHAR(10) PRIMARY KEY,
    MaNCC VARCHAR(10),
    MaND VARCHAR(10),
    TongTienNhap DECIMAL(18,2),
    NgayNhap DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaNCC) REFERENCES NhaCungCap(MaNCC),
    FOREIGN KEY (MaND) REFERENCES NguoiDung(MaND)
);
GO

-- 13. Bảng Chi Tiết Phiếu Nhập
CREATE TABLE ChiTietPhieuNhap (
    MaCTPhieuNhap VARCHAR(10) PRIMARY KEY,
    MaPhieuNhap VARCHAR(10),
    MaSach VARCHAR(10),
    SoLuong INT NOT NULL,
    Gianhap DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (MaPhieuNhap) REFERENCES PhieuNhapKho(MaPhieuNhap),
    FOREIGN KEY (MaSach) REFERENCES Sach(MaSach)
);
GO

-- 14. Bảng Phiếu Đánh Giá
CREATE TABLE PhieuDanhGia (
    MaPDG VARCHAR(10) PRIMARY KEY,
    MaSach VARCHAR(10),
    MaND VARCHAR(10),
    SoSao INT CHECK (SoSao BETWEEN 1 AND 5),
    NoiDung NVARCHAR(500),
    NgayDanhGia DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MaSach) REFERENCES Sach(MaSach),
    FOREIGN KEY (MaND) REFERENCES NguoiDung(MaND)
);
GO

--------------------------------------------------------------------------------
-- 1. Bảng Tác Giả
--------------------------------------------------------------------------------
INSERT INTO TacGia (MaTG, TenTG, TieuSu) VALUES
('TG01', N'Nguyễn Nhật Ánh', N'Nhà văn nổi tiếng với các tác phẩm viết cho tuổi mới lớn và thiếu nhi Việt Nam.'),
('TG02', N'Haruki Murakami', N'Nhà văn đương đại Nhật Bản với phong cách hiện thực huyền ảo.'),
('TG03', N'Robert C. Martin', N'Kỹ sư phần mềm và tác giả kỳ cựu về kiến trúc phần mềm.'),
('TG04', N'Rosie Nguyễn', N'Tác giả, blogger chia sẻ về kỹ năng sống và phát triển bản thân.'),
('TG05', N'Yuval Noah Harari', N'Sử gia và giáo sư người Israel, tác giả loạt sách lịch sử nhân loại.'),
('TG06', N'Tô Hoài', N'Nhà văn lớn của văn học Việt Nam hiện đại.'),
('TG07', N'Nam Cao', N'Nhà văn hiện thực xuất sắc với những truyện ngắn đi sâu vào bi kịch.'),
('TG08', N'Nguyễn Tuân', N'Cây bút bậc thầy về tùy bút và ngôn ngữ giàu chất tài hoa.'),
('TG09', N'J.K. Rowling', N'Nhà văn người Anh nổi tiếng với loạt tiểu thuyết giả tưởng kỳ ảo.'),
('TG10', N'George Orwell', N'Nhà văn, nhà báo người Anh với các tác phẩm châm biếm chính trị.'),
('TG11', N'Paulo Coelho', N'Nhà văn Brazil với những tiểu thuyết mang màu sắc triết lý.'),
('TG12', N'Dale Carnegie', N'Nhà văn và diễn giả người Mỹ tiên phong về nghệ thuật giao tiếp.'),
('TG13', N'Cal Newport', N'Giáo sư khoa học máy tính và tác giả sách về làm việc sâu.'),
('TG14', N'James Clear', N'Tác giả chuyên nghiên cứu về thói quen và ra quyết định.'),
('TG15', N'Martin Kleppmann', N'Kỹ sư hệ thống phân tán và tác giả sách dữ liệu.'),
('TG16', N'Andrew S. Tanenbaum', N'Giáo sư khoa học máy tính nổi tiếng về hệ điều hành.'),
('TG17', N'Đặng Hoàng Giang', N'Nhà nghiên cứu, cây bút chính luận và tâm lý xã hội.'),
('TG18', N'Phan Việt', N'Tác giả các cuốn tản văn và sách trải nghiệm sống.'),
('TG19', N'Kazuo Ishiguro', N'Nhà văn người Anh gốc Nhật, chủ nhân giải Nobel Văn học.'),
('TG20', N'Khaled Hosseini', N'Nhà văn người Mỹ gốc Afghanistan giàu tính nhân văn.');
GO

--------------------------------------------------------------------------------
-- 2. Bảng Danh Mục
--------------------------------------------------------------------------------
INSERT INTO DanhMuc (MaDM, TenDM, MoTa) VALUES
('DM01', N'Văn học Việt Nam', N'Tiểu thuyết, truyện ngắn, tản văn Việt Nam.'),
('DM02', N'Văn học Nước ngoài', N'Các tác phẩm văn học dịch kinh điển.'),
('DM03', N'Công nghệ thông tin', N'Sách chuyên ngành lập trình, cơ sở dữ liệu.'),
('DM04', N'Kỹ năng sống', N'Sách phát triển bản thân và quản trị cuộc đời.'),
('DM05', N'Lịch sử - Xã hội', N'Nghiên cứu lịch sử, văn hóa và kinh tế.'),
('DM06', N'Thiếu nhi', N'Truyện đồng thoại và sách giáo dục sớm.'),
('DM07', N'Tâm lý học', N'Khám phá hành vi và sức khỏe tinh thần.'),
('DM08', N'Kinh tế - Quản trị', N'Chiến lược kinh doanh, tài chính cá nhân.'),
('DM09', N'Khoa học tự nhiên', N'Vật lý, thiên văn học và sinh học.'),
('DM10', N'Triết học', N'Tư tưởng triết học Đông - Tây.'),
('DM11', N'Giả tưởng - Kỳ ảo', N'Thế giới hư cấu và phép thuật.'),
('DM12', N'Trinh thám - Kinh dị', N'Tiểu thuyết phá án và tâm lý tội phạm.'),
('DM13', N'Tản văn - Tùy bút', N'Những trang viết giàu cảm xúc.'),
('DM14', N'Ngoại ngữ', N'Giáo trình và từ vựng ngoại ngữ.'),
('DM15', N'Nghệ thuật - Thiết kế', N'Mỹ thuật, kiến trúc và nhiếp ảnh.'),
('DM16', N'Du lịch - Khám phá', N'Hồi ký hành trình và cẩm nang xê dịch.'),
('DM17', N'Ẩm thực - Đời sống', N'Văn hóa ẩm thực và lối sống lành mạnh.'),
('DM18', N'Tiểu sử - Hồi ký', N'Câu chuyện cuộc đời các nhân vật đáng chú ý.'),
('DM19', N'Giáo dục - Nuôi dạy con', N'Phương pháp sư phạm và nuôi dạy trẻ.'),
('DM20', N'Sách chuyên khảo', N'Tài liệu nghiên cứu học thuật chuyên sâu.');
GO

--------------------------------------------------------------------------------
-- 3. Bảng Nhà Xuất Bản
--------------------------------------------------------------------------------
INSERT INTO NhaXuatBan (MaNXB, TenNXB, Diachi) VALUES
('NXB01', N'NXB Trẻ', N'Quận 3, TP.HCM'),
('NXB02', N'NXB Hội Nhà Văn', N'Hoàn Kiếm, Hà Nội'),
('NXB03', N'NXB Thông Tin và Truyền Thông', N'Cầu Giấy, Hà Nội'),
('NXB04', N'NXB Thế Giới', N'Hoàn Kiếm, Hà Nội'),
('NXB05', N'NXB Kim Đồng', N'Hai Bà Trưng, Hà Nội'),
('NXB06', N'NXB Văn Học', N'Ba Đình, Hà Nội'),
('NXB07', N'NXB Lao Động', N'Đống Đa, Hà Nội'),
('NXB08', N'NXB Tổng Hợp TP.HCM', N'Quận 1, TP.HCM'),
('NXB09', N'NXB Khoa Học và Kỹ Thuật', N'Hoàn Kiếm, Hà Nội'),
('NXB10', N'NXB Chính Trị Quốc Gia Sự Thật', N'Hoàn Kiếm, Hà Nội'),
('NXB11', N'NXB Phụ Nữ Việt Nam', N'Hai Bà Trưng, Hà Nội'),
('NXB12', N'NXB Giáo Dục Việt Nam', N'Hoàn Kiếm, Hà Nội'),
('NXB13', N'NXB Đại Học Quốc Gia Hà Nội', N'Cầu Giấy, Hà Nội'),
('NXB14', N'NXB Đại Học Quốc Gia TP.HCM', N'TP. Thủ Đức, TP.HCM'),
('NXB15', N'NXB Mỹ Thuật', N'Hoàn Kiếm, Hà Nội'),
('NXB16', N'NXB Dân Trí', N'Đống Đa, Hà Nội'),
('NXB17', N'NXB Hồng Đức', N'Hoàn Kiếm, Hà Nội'),
('NXB18', N'NXB Công Thương', N'Bắc Từ Liêm, Hà Nội'),
('NXB19', N'NXB Thanh Niên', N'Hoàn Kiếm, Hà Nội'),
('NXB20', N'NXB Quân Đội Nhân Dân', N'Hoàn Kiếm, Hà Nội');
GO

--------------------------------------------------------------------------------
-- 4. Bảng Người Dùng 
--------------------------------------------------------------------------------
INSERT INTO NguoiDung (MaND, HoTen, Email, SDT, MatKhau, VaiTro, Active) VALUES
('ND01', N'Trần Minh Khoa', N'khoa.tran@example.com', '0901234501', 'hashed_pass', N'Khách hàng', 1),
('ND02', N'Lê Thị Thu Hà', N'ha.le@example.com', '0901234502', 'hashed_pass', N'Khách hàng', 1),
('ND03', N'Phạm Quốc Bảo', N'bao.pham@example.com', '0901234503', 'hashed_pass', N'Khách hàng', 1),
('ND04', N'Nguyễn Hoàng Anh', N'anh.nguyen@example.com', '0901234504', 'hashed_pass', N'Khách hàng', 1),
('ND05', N'Đỗ Thanh Tâm', N'tam.do@example.com', '0901234505', 'hashed_pass', N'Quản trị', 1),
('ND06', N'Vũ Đức Minh', N'minh.vu@example.com', '0901234506', 'hashed_pass', N'Khách hàng', 1),
('ND07', N'Bùi Ngọc Lan', N'lan.bui@example.com', '0901234507', 'hashed_pass', N'Khách hàng', 1),
('ND08', N'Đặng Tuấn Kiệt', N'kiet.dang@example.com', '0901234508', 'hashed_pass', N'Khách hàng', 1),
('ND09', N'Ngô Phương Thảo', N'thao.ngo@example.com', '0901234509', 'hashed_pass', N'Khách hàng', 1),
('ND10', N'Hoàng Gia Huy', N'huy.hoang@example.com', '0901234510', 'hashed_pass', N'Nhân viên', 1),
('ND11', N'Phan Mỹ Linh', N'linh.phan@example.com', '0901234511', 'hashed_pass', N'Khách hàng', 1),
('ND12', N'Lý Văn Nam', N'nam.ly@example.com', '0901234512', 'hashed_pass', N'Khách hàng', 1),
('ND13', N'Trịnh Khánh Vy', N'vy.trinh@example.com', '0901234513', 'hashed_pass', N'Khách hàng', 1),
('ND14', N'Đoàn Minh Quân', N'quan.doan@example.com', '0901234514', 'hashed_pass', N'Khách hàng', 1),
('ND15', N'Mai Anh Thư', N'thu.mai@example.com', '0901234515', 'hashed_pass', N'Khách hàng', 1),
('ND16', N'Dương Quốc Việt', N'viet.duong@example.com', '0901234516', 'hashed_pass', N'Khách hàng', 1),
('ND17', N'Cao Thị Bích Ngọc', N'ngoc.cao@example.com', '0901234517', 'hashed_pass', N'Nhân viên', 1),
('ND18', N'Hồ Trọng Nhân', N'nhan.ho@example.com', '0901234518', 'hashed_pass', N'Khách hàng', 1),
('ND19', N'Tạ Hải Yến', N'yen.ta@example.com', '0901234519', 'hashed_pass', N'Khách hàng', 1),
('ND20', N'Lưu Nhật Minh', N'minh.luu@example.com', '0901234520', 'hashed_pass', N'Khách hàng', 1);
GO

--------------------------------------------------------------------------------
-- 5. Bảng Nhà Cung Cấp 
--------------------------------------------------------------------------------
INSERT INTO NhaCungCap (MaNCC, TenNCC, DiaChi, SDT, Email) VALUES
('NCC01', N'Công ty CP Phát hành Sách Fahasa', N'Quận 1, TP.HCM', '02838225701', 'contact01@fahasa.com'),
('NCC02', N'Công ty Văn hóa & Truyền thông Nhã Nam', N'Cầu Giấy, Hà Nội', '02435146802', 'info02@nhanam.vn'),
('NCC03', N'Alpha Books', N'Đống Đa, Hà Nội', '02437226203', 'support03@alphabooks.vn'),
('NCC04', N'Đông A Books', N'Cầu Giấy, Hà Nội', '02437823104', 'sales04@dongabooks.vn'),
('NCC05', N'Ipad Việt Nam', N'Đống Đa, Hà Nội', '02437758105', 'cskh05@ipadvietnam.vn'),
('NCC06', N'Công ty CP Sách Thái Hà', N'Gò Vấp, TP.HCM', '02838945606', 'contact06@thaihabooks.com'),
('NCC07', N'Công ty TNHH Sách và Thiết bị Giáo dục', N'Quận 1, TP.HCM', '02838291107', 'info07@sachgiaoduc.vn'),
('NCC08', N'First News - Trí Việt', N'Quận 1, TP.HCM', '02838227908', 'support08@firstnews.com.vn'),
('NCC09', N'Omega Plus', N'Đống Đa, Hà Nội', '02435381209', 'sales09@omegaplus.vn'),
('NCC10', N'1980 Books', N'Cầu Giấy, Hà Nội', '02466845210', 'cskh10@1980books.vn'),
('NCC11', N'Bách Việt Books', N'Thanh Xuân, Hà Nội', '02435527811', 'contact11@bachvietbooks.com'),
('NCC12', N'Saigon Books', N'Quận 1, TP.HCM', '02839251912', 'info12@saigonbooks.vn'),
('NCC13', N'Minh Long Book', N'Quận 11, TP.HCM', '02838582313', 'support13@minhlongbook.vn'),
('NCC14', N'Tân Việt Books', N'Cầu Giấy, Hà Nội', '02437932114', 'sales14@tanvietbooks.vn'),
('NCC15', N'Văn Lang Books', N'Đống Đa, Hà Nội', '02437759015', 'cskh15@vanlangbooks.vn'),
('NCC16', N'Quảng Văn', N'Quận 1, TP.HCM', '02838364516', 'contact16@quangvan.vn'),
('NCC17', N'Đinh Tị Books', N'Cầu Giấy, Hà Nội', '02437673317', 'info17@dinhtibooks.vn'),
('NCC18', N'Cộng đồng Sách Việt', N'Nam Từ Liêm, Hà Nội', '02462918818', 'support18@sachviet.vn'),
('NCC19', N'Nhà Sách Cá Chép', N'Quận 3, TP.HCM', '02838328919', 'sales19@cachep.vn'),
('NCC20', N'Tri Thức Trẻ Books', N'Quận 3, TP.HCM', '02839316220', 'cskh20@trithuctre.vn');
GO

--------------------------------------------------------------------------------
-- 6. Bảng Khuyến Mãi 
--------------------------------------------------------------------------------
INSERT INTO KhuyenMai (MaKM, TenKM, PhanTramGiam, NgayBatDau, NgayKetThuc, MoTa) VALUES
('KM01', N'Chào mừng thành viên mới', 10, '2026-01-01', '2026-12-31', N'Giảm 10% đơn hàng đầu tiên'),
('KM02', N'Siêu sale tháng 11', 20, '2026-11-01', '2026-11-30', N'Giảm 20% toàn bộ sách văn học'),
('KM03', N'Tuần lễ sách Công nghệ', 15, '2026-11-10', '2026-11-25', N'Ưu đãi 15% sách CNTT'),
('KM04', N'Combo mùa đông ấm áp', 25, '2026-11-15', '2026-12-20', N'Giảm 25% mua từ 3 cuốn'),
('KM05', N'Tri ân khách hàng thân thiết', 12, '2026-10-01', '2026-12-31', N'Áp dụng khách mua từ 5 đơn'),
('KM06', N'Ưu đãi đầu năm 2026', 15, '2026-01-02', '2026-01-31', N'Giảm 15% khai xuân'),
('KM07', N'Mừng Tết Nguyên Đán', 20, '2026-02-01', '2026-02-20', N'Lì xì giảm giá 20%'),
('KM08', N'Quốc tế Phụ nữ 8/3', 18, '2026-03-01', '2026-03-10', N'Giảm 18% sách văn học, tâm lý'),
('KM09', N'Ngày Sách Việt Nam 21/4', 25, '2026-04-15', '2026-04-25', N'Ưu đãi lớn chào mừng Ngày Sách'),
('KM10', N'Đại lễ 30/4 - 1/5', 15, '2026-04-28', '2026-05-04', N'Giảm 15% sách lịch sử, du lịch'),
('KM11', N'Quốc tế Thiếu nhi 1/6', 20, '2026-05-25', '2026-06-05', N'Giảm 20% sách thiếu nhi'),
('KM12', N'Mùa hè đọc sách', 15, '2026-06-10', '2026-07-31', N'Ưu đãi xuyên hè cho học sinh, sinh viên'),
('KM13', N'Ngày Gia đình Việt Nam', 12, '2026-06-20', '2026-06-30', N'Giảm 12% sách nuôi dạy con'),
('KM14', N'Tựu trường rộn ràng', 20, '2026-08-15', '2026-09-15', N'Giảm 20% sách tham khảo'),
('KM15', N'Quốc khánh 2/9', 18, '2026-08-30', '2026-09-05', N'Ưu đãi đặc biệt dịp Quốc khánh'),
('KM16', N'Trung thu sum vầy', 15, '2026-09-15', '2026-09-28', N'Giảm 15% combo quà tặng'),
('KM17', N'Ngày Chuyển đổi số 10/10', 20, '2026-10-08', '2026-10-15', N'Giảm 20% sách công nghệ và AI'),
('KM18', N'Phụ nữ Việt Nam 20/10', 18, '2026-10-15', '2026-10-22', N'Ưu đãi 18% sách phát triển bản thân'),
('KM19', N'Ngày Nhà giáo Việt Nam 20/11', 22, '2026-11-15', '2026-11-22', N'Tri ân thầy cô giảm 22%'),
('KM20', N'Giáng sinh an lành', 25, '2026-12-15', '2026-12-26', N'Ưu đãi mùa lễ hội cuối năm');
GO

--------------------------------------------------------------------------------
-- 7. Bảng Sách
--------------------------------------------------------------------------------
INSERT INTO Sach (MaSach,TenSach, SoLuongTon, GiaBan, HinhAnh, MoTa) VALUES
('S01', N'Mắt Biếc', 45, 110000, 's01.jpg', N'Chuyện tình đơn phương.'),
('S02', N'Rừng Na Uy', 30, 165000, 's02.jpg', N'Tuổi trẻ và sự mất mát.'),
('S03', N'Clean Code - Mã Sạch', 20, 320000, 's03.jpg', N'Cẩm nang viết mã nguồn chuẩn.'),
('S04', N'Tuổi Trẻ Đáng Giá Bao Nhiêu', 60, 95000, 's04.jpg', N'Góc nhìn tự học và trưởng thành.'),
('S05', N'Sapiens: Lược Sử Loài Người', 25, 240000, 's05.jpg', N'Hành trình tiến hóa loài người.'),
('S06', N'Dế Mèn Phiêu Lưu Ký', 80, 75000, 's06.jpg', N'Tác phẩm thiếu nhi kinh điển.'),
('S07', N'Chí Phèo', 50, 65000, 's07.jpg', N'Truyện ngắn hiện thực.'),
('S08', N'Vang Bóng Một Thời', 35, 120000, 's08.jpg', N'Tùy bút lưu giữ nét đẹp xưa.'),
('S09', N'Harry Potter và Hòn Đá Phù Thủy', 55, 185000, 's09.jpg', N'Phiêu lưu tại Hogwarts.'),
('S10', N'1984', 40, 145000, 's10.jpg', N'Tiểu thuyết phản địa đàng.'),
('S11', N'Nhà Giả Kim', 70, 90000, 's11.jpg', N'Hành trình đi tìm vận mệnh.'),
('S12', N'Đắc Nhân Tâm', 90, 115000, 's12.jpg', N'Nghệ thuật thu phục lòng người.'),
('S13', N'Deep Work - Làm Việc Sâu', 28, 175000, 's13.jpg', N'Phương pháp tập trung cao độ.'),
('S14', N'Atomic Habits', 65, 190000, 's14.jpg', N'Xây dựng thói quen nguyên tử.'),
('S15', N'Designing Data-Intensive Applications', 15, 450000, 's15.jpg', N'Kiến trúc dữ liệu quy mô lớn.'),
('S16', N'Modern Operating Systems', 18, 380000, 's16.jpg', N'Giáo trình hệ điều hành.'),
('S17', N'Miền Đất Phúc', 32, 135000, 's17.jpg', N'Suy tư xã hội và con người.'),
('S18', N'Đi Tìm Lẽ Sống', 48, 105000, 's18.jpg', N'Trải nghiệm ý nghĩa tồn tại.'),
('S19', N'Không Gia Đình', 38, 160000, 's19.jpg', N'Nghị lực của cậu bé Remi.'),
('S20', N'Người Đua Diều', 42, 155000, 's20.jpg', N'Tiểu thuyết tình bạn và chuộc lỗi.');
GO

--------------------------------------------------------------------------------
-- 8. Bảng Giỏ Hàng
--------------------------------------------------------------------------------
INSERT INTO GioHang (MaGioHang, NgayTao) VALUES
('GH01', DEFAULT), ('GH02', DEFAULT), ('GH03', DEFAULT), ('GH04', DEFAULT),
('GH05', DEFAULT), ('GH06', DEFAULT), ('GH07', DEFAULT), ('GH08', DEFAULT),
('GH09', DEFAULT), ('GH10', DEFAULT), ('GH11', DEFAULT), ('GH12', DEFAULT),
('GH13', DEFAULT), ('GH14', DEFAULT), ('GH15', DEFAULT), ('GH16', DEFAULT),
('GH17', DEFAULT), ('GH18', DEFAULT), ('GH19', DEFAULT), ('GH20', DEFAULT);
GO

--------------------------------------------------------------------------------
-- 9. Bảng Chi Tiết Giỏ Hàng (Do MaGioHang và MaSach là Khóa chính nên phải có giá trị)
--------------------------------------------------------------------------------
INSERT INTO ChiTietGioHang (SoLuong) VALUES
(1), (2), (1), (3),
(1), (2), (1), (4),
(1), (2), (1), (3),
(2), (1), (1), (2),
(1), (2), (1), (3);
GO

--------------------------------------------------------------------------------
-- 10. Bảng Đơn Hàng
--------------------------------------------------------------------------------
INSERT INTO DonHang (MaDH, TTTT, TTDH, NgayDat, TongTien, DiaChiGiaoHang, PhuongThucTT) VALUES
('DH01', 1, 1, DEFAULT, 240000, N'12 Nguyễn Huệ, Q.1, TP.HCM', N'Chuyển khoản'),
('DH02', 2, 2, DEFAULT, 148500, N'45 Láng Hạ, Ba Đình, Hà Nội', N'COD'),
('DH03', 1, 3, DEFAULT, 272000, N'88 Lê Lợi, Hải Châu, Đà Nẵng', N'Ví điện tử'),
('DH04', 2, 1, DEFAULT, 240000, N'102 Trần Hưng Đạo, Cần Thơ', N'COD'),
('DH05', 2, 4, DEFAULT, 390000, N'161B Lý Chính Thắng, Q.3, TP.HCM', N'Thẻ tín dụng'),
('DH06', 1, 2, DEFAULT, 195000, N'24 Phan Đình Phùng, Hà Nội', N'Chuyển khoản'),
('DH07', 2, 3, DEFAULT, 320000, N'55 Võ Văn Tần, Q.3, TP.HCM', N'Ví điện tử'),
('DH08', 1, 1, DEFAULT, 110000, N'19 Bạch Đằng, Hải Phòng', N'COD'),
('DH09', 2, 3, DEFAULT, 450000, N'77 Trần Phú, Nha Trang', N'Thẻ tín dụng'),
('DH10', 2, 2, DEFAULT, 185000, N'31 Nguyễn Văn Cừ, Q.5, TP.HCM', N'Chuyển khoản'),
('DH11', 1, 3, DEFAULT, 285000, N'14 Hai Bà Trưng, Hà Nội', N'Ví điện tử'),
('DH12', 2, 1, DEFAULT, 165000, N'90 Hùng Vương, Huế', N'COD'),
('DH13', 2, 2, DEFAULT, 510000, N'120 CMT8, Q.10, TP.HCM', N'Chuyển khoản'),
('DH14', 1, 3, DEFAULT, 220000, N'63 Lê Duẩn, Đà Nẵng', N'Thẻ tín dụng'),
('DH15', 2, 4, DEFAULT, 175000, N'08 Hoàng Hoa Thám, Hà Nội', N'Ví điện tử'),
('DH16', 2, 2, DEFAULT, 360000, N'205 Điện Biên Phủ, Bình Thạnh', N'Chuyển khoản'),
('DH17', 1, 1, DEFAULT, 145000, N'52 Lý Tự Trọng, Cần Thơ', N'COD'),
('DH18', 2, 3, DEFAULT, 295000, N'83 Cầu Giấy, Hà Nội', N'Ví điện tử'),
('DH19', 2, 2, DEFAULT, 410000, N'17 Nguyễn Trãi, Q.1, TP.HCM', N'Thẻ tín dụng'),
('DH20', 1, 3, DEFAULT, 190000, N'99 Quang Trung, Gò Vấp, TP.HCM', N'Chuyển khoản');
GO

--------------------------------------------------------------------------------
-- 11. Bảng Chi Tiết Đơn Hàng
--------------------------------------------------------------------------------
INSERT INTO ChiTietDonHang (SoLuong, DonGia) VALUES
(1, 110000), (1, 130000), (1, 148500), (1, 272000),
(1, 240000), (2, 195000), (1, 320000), (1, 110000),
(2, 225000), (1, 185000), (2, 142500), (1, 165000),
(3, 170000), (2, 110000), (1, 175000), (2, 180000),
(1, 145000), (2, 147500), (2, 205000), (1, 190000);
GO

--------------------------------------------------------------------------------
-- 12. Bảng Phiếu Nhập Kho
--------------------------------------------------------------------------------
INSERT INTO PhieuNhapKho (MaPhieuNhap, TongTienNhap, NgayNhap) VALUES
('PN01', 4250000, DEFAULT), ('PN02', 3750000, DEFAULT),
('PN03', 4800000, DEFAULT), ('PN04', 4080000, DEFAULT),
('PN05', 4500000, DEFAULT), ('PN06', 2500000, DEFAULT),
('PN07', 2100000, DEFAULT), ('PN08', 3520000, DEFAULT),
('PN09', 5400000, DEFAULT), ('PN10', 3150000, DEFAULT),
('PN11', 2480000, DEFAULT), ('PN12', 3900000, DEFAULT),
('PN13', 3640000, DEFAULT), ('PN14', 4200000, DEFAULT),
('PN15', 5250000, DEFAULT), ('PN16', 4350000, DEFAULT),
('PN17', 2880000, DEFAULT), ('PN18', 2160000, DEFAULT),
('PN19', 3450000, DEFAULT), ('PN20', 3360000, DEFAULT);
GO

--------------------------------------------------------------------------------
-- 13. Bảng Chi Tiết Phiếu Nhập
--------------------------------------------------------------------------------
INSERT INTO ChiTietPhieuNhap (MaCTPhieuNhap, SoLuong, Gianhap) VALUES
('CTPN01', 50, 85000), ('CTPN02', 30, 125000),
('CTPN03', 20, 240000), ('CTPN04', 60, 68000),
('CTPN05', 25, 180000), ('CTPN06', 50, 50000),
('CTPN07', 50, 42000), ('CTPN08', 40, 88000),
('CTPN09', 40, 135000), ('CTPN10', 30, 105000),
('CTPN11', 40, 62000), ('CTPN12', 50, 78000),
('CTPN13', 28, 130000), ('CTPN14', 30, 140000),
('CTPN15', 15, 350000), ('CTPN16', 15, 290000),
('CTPN17', 30, 96000), ('CTPN18', 30, 72000),
('CTPN19', 30, 115000), ('CTPN20', 30, 112000);
GO

--------------------------------------------------------------------------------
-- 14. Bảng Phiếu Đánh Giá
--------------------------------------------------------------------------------
INSERT INTO PhieuDanhGia (MaPDG, SoSao, NoiDung, NgayDanhGia) VALUES
('PDG01', 5, N'Truyện nhẹ nhàng, sâu lắng, xúc động.', DEFAULT),
('PDG02', 4, N'Dịch mượt, không khí truyện cuốn hút.', DEFAULT),
('PDG03', 5, N'Rất đáng đọc để cải thiện chất lượng code.', DEFAULT),
('PDG04', 5, N'Nhiều góc nhìn mở mang tư duy.', DEFAULT),
('PDG05', 4, N'Gần gũi, dễ áp dụng cho người mới.', DEFAULT),
('PDG06', 5, N'Hình ảnh sinh động, thú vị.', DEFAULT),
('PDG07', 4, N'Văn phong sắc bén, phản ánh chân thực.', DEFAULT),
('PDG08', 5, N'Ngôn ngữ giàu chất nghệ thuật.', DEFAULT),
('PDG09', 5, N'Thế giới kỳ ảo hấp dẫn.', DEFAULT),
('PDG10', 4, N'Cốt truyện chặt chẽ, đáng suy ngẫm.', DEFAULT),
('PDG11', 5, N'Truyền cảm hứng tích cực.', DEFAULT),
('PDG12', 5, N'Ví dụ thực tế dễ áp dụng vào giao tiếp.', DEFAULT),
('PDG13', 4, N'Giúp sắp xếp thời gian hiệu quả.', DEFAULT),
('PDG14', 5, N'Trình bày rõ ràng, dễ thực hiện.', DEFAULT),
('PDG15', 5, N'Kiến thức hệ thống sâu sắc.', DEFAULT),
('PDG16', 4, N'Giải thích hệ điều hành bài bản.', DEFAULT),
('PDG17', 5, N'Góc nhìn nhân văn về xã hội.', DEFAULT),
('PDG18', 5, N'Trân trọng hơn giá trị sự lựa chọn.', DEFAULT),
('PDG19', 4, N'Cảm động và giàu lòng trắc ẩn.', DEFAULT),
('PDG20', 5, N'Cảm xúc dâng trào từ đầu đến cuối.', DEFAULT);
GO