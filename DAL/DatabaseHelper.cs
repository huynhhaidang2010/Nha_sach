using System;
using System.Data;
using Microsoft.Data.SqlClient;

namespace QuanLyBanHang.DAL
{
    public class DatabaseHelper
    {
        // Thay "YOUR_SERVER_NAME" bằng tên Server SQL của máy bạn (ví dụ: DESKTOP-ABC\SQLEXPRESS hoặc localhost)
        // Thay "QuanLyBanHang" bằng tên Database của nhóm bạn trên SQL Server
        private static string connString = @"Server=YOUR_SERVER_NAME;Database=QuanLyBanHang;Trusted_Connection=True;TrustServerCertificate=True;";

        // Hàm lấy dữ liệu (SELECT) trả về bảng (DataTable) để đổ lên giao diện
        public static DataTable ExecuteQuery(string query)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }
            }
            return dt;
        }

        // Hàm thực thi thêm, sửa, xóa (INSERT, UPDATE, DELETE) - trả về số dòng thay đổi
        public static int ExecuteNonQuery(string query)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    return cmd.ExecuteNonQuery();
                }
            }
        }
    }
}