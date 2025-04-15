import util.DBConnection;
import javax.swing.*;
import java.awt.event.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LoginForm extends JFrame {
    private JTextField emailField;
    private JPasswordField passwordField;
    private JButton loginButton, registerButton;

    public LoginForm() {
        setTitle("Login");
        setSize(350, 250);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(null);

        JLabel emailLabel = new JLabel("Email:");
        emailLabel.setBounds(30, 30, 100, 30);
        add(emailLabel);

        emailField = new JTextField();
        emailField.setBounds(120, 30, 150, 30);
        add(emailField);

        JLabel passwordLabel = new JLabel("Password:");
        passwordLabel.setBounds(30, 70, 100, 30);
        add(passwordLabel);

        passwordField = new JPasswordField();
        passwordField.setBounds(120, 70, 150, 30);
        add(passwordField);

        loginButton = new JButton("Login");
        loginButton.setBounds(30, 120, 100, 30);
        add(loginButton);

        registerButton = new JButton("Register");
        registerButton.setBounds(170, 120, 100, 30);
        add(registerButton);

        loginButton.addActionListener(e -> loginUser());
        registerButton.addActionListener(e -> {
            new RegisterForm().setVisible(true);
            dispose();
        });

        setLocationRelativeTo(null);
    }

    private void loginUser() {
        String email = emailField.getText();
        String password = new String(passwordField.getPassword());

        if (email.isEmpty() || password.isEmpty()) {
            JOptionPane.showMessageDialog(this, "All fields are required!");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String query = "SELECT * FROM users WHERE email=? AND password=?";
            PreparedStatement pst = conn.prepareStatement(query);
            pst.setString(1, email);
            pst.setString(2, password);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                JOptionPane.showMessageDialog(this, "Login Successful!");
                new Dashboard().setVisible(true); // Open Dashboard
                dispose();
            } else {
                JOptionPane.showMessageDialog(this, "Invalid email or password!");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public static void main(String[] args) {
        new LoginForm().setVisible(true);
    }
}
