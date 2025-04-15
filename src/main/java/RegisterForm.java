import util.DBConnection;
import javax.swing.*;
import java.awt.event.*;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class RegisterForm extends JFrame {
    private JTextField nameField, emailField;
    private JPasswordField passwordField;
    private JButton registerButton, loginButton;

    public RegisterForm() {
        setTitle("Register");
        setSize(350, 300);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(null);

        JLabel nameLabel = new JLabel("Name:");
        nameLabel.setBounds(30, 30, 100, 30);
        add(nameLabel);
        
        nameField = new JTextField();
        nameField.setBounds(120, 30, 150, 30);
        add(nameField);

        JLabel emailLabel = new JLabel("Email:");
        emailLabel.setBounds(30, 70, 100, 30);
        add(emailLabel);
        
        emailField = new JTextField();
        emailField.setBounds(120, 70, 150, 30);
        add(emailField);

        JLabel passwordLabel = new JLabel("Password:");
        passwordLabel.setBounds(30, 110, 100, 30);
        add(passwordLabel);
        
        passwordField = new JPasswordField();
        passwordField.setBounds(120, 110, 150, 30);
        add(passwordField);

        registerButton = new JButton("Register");
        registerButton.setBounds(30, 160, 100, 30);
        add(registerButton);

        loginButton = new JButton("Login");
        loginButton.setBounds(170, 160, 100, 30);
        add(loginButton);

        registerButton.addActionListener(e -> registerUser());
        loginButton.addActionListener(e -> {
            new LoginForm().setVisible(true);
            dispose();
        });

        setLocationRelativeTo(null);
    }

    private void registerUser() {
        String name = nameField.getText();
        String email = emailField.getText();
        String password = new String(passwordField.getPassword());

        if (name.isEmpty() || email.isEmpty() || password.isEmpty()) {
            JOptionPane.showMessageDialog(this, "All fields are required!");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String query = "INSERT INTO users (name, email, password) VALUES (?, ?, ?)";
            PreparedStatement pst = conn.prepareStatement(query);
            pst.setString(1, name);
            pst.setString(2, email);
            pst.setString(3, password);
            pst.executeUpdate();

            JOptionPane.showMessageDialog(this, "Registration Successful!");
            new LoginForm().setVisible(true);
            dispose();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public static void main(String[] args) {
        new RegisterForm().setVisible(true);
    }
}
