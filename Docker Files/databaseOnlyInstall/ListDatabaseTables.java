
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ListDatabaseTables {

	/*
	 * Simple application to list the tables present in a 
	 * database accessible via the provided JDBC URL
	 */
	
	public static void main(String args[]) throws Exception{

		String user = "";
		String pass = "";
		String url = null;
		
		for (String arg : args) {
			if (arg.startsWith("url:")) {
				url = arg.substring(4);
			}
			if (arg.startsWith("user:")) {
				user = arg.substring(5);
			}
			if (arg.startsWith("password:")) {
				pass = arg.substring(9);
			}
			if (arg.equals("showclasspath")) {
				System.out.println("Classpath: " + System.getProperty("java.class.path"));
			}
		}
		
		if (args.length == 0 || url==null) {
			System.out.println("Database Table Listing");
			System.out.println("==========================");
			System.out.println("");
			System.out.println(" Required Parameters: ");
			System.out.println("");
			System.out.println(" url:<JDBC URL>            JDBC URL to database ");
			System.out.println(" user:<Database User>      Database User ");
			System.out.println(" password:<User Password>  Database User Password ");
			System.out.println(" showclasspath             Show Java's classpath ");
			System.exit(1);
		}
		
		try (Connection c = DriverManager.getConnection(url, user, pass) ) {
			
			ResultSet rs = c.getMetaData().getTables(null, null, null, new String[] { "TABLE"});

			while (rs.next()) {
				System.out.println(rs.getString(3).toUpperCase());
			}

		} catch (SQLException  e) {
			System.err.println("Unable to connect to database: " + url);
			e.printStackTrace(System.err);
			System.exit(1);
		}
		System.exit(0);
	}

};
