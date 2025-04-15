import javax.swing.*;

public class Dashboard extends JFrame {
    public Dashboard() {
        setTitle("Dashboard");
        setSize(300, 200);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(null);

        JLabel welcomeLabel = new JLabel("Welcome to the Dashboard!");
        welcomeLabel.setBounds(50, 50, 200, 30);
        add(welcomeLabel);

        setLocationRelativeTo(null);
    }

    public static void main(String[] args) {
        new Dashboard().setVisible(true);
    }
}
