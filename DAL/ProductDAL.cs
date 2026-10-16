using System.Data;

namespace QuanLyBanHang.DAL
{
    public class ProductDAL
    {
        // 1. READ: Lấy toàn bộ danh sách sản phẩm
        public DataTable GetAllProducts()
        {
            return DatabaseHelper.ExecuteQuery("SELECT * FROM Products");
        }

        // 2. CREATE: Thêm sản phẩm mới
        public bool InsertProduct(string name, decimal price, int stock)
        {
            string query = $"INSERT INTO Products (ProductName, Price, Stock) VALUES (N'{name}', {price}, {stock})";
            return DatabaseHelper.ExecuteNonQuery(query) > 0;
        }

        // 3. UPDATE: Cập nhật sản phẩm theo ID
        public bool UpdateProduct(int id, string name, decimal price, int stock)
        {
            string query = $"UPDATE Products SET ProductName = N'{name}', Price = {price}, Stock = {stock} WHERE ProductID = {id}";
            return DatabaseHelper.ExecuteNonQuery(query) > 0;
        }

        // 4. DELETE: Xóa sản phẩm theo ID
        public bool DeleteProduct(int id)
        {
            string query = $"DELETE FROM Products WHERE ProductID = {id}";
            return DatabaseHelper.ExecuteNonQuery(query) > 0;
        }
    }
}