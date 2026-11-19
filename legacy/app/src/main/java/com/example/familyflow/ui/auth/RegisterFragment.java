package com.example.familyflow.ui.auth;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.fragment.NavHostFragment;

import com.example.familyflow.R;

public class RegisterFragment extends Fragment {

    private EditText etUsername, etPassword;
    private Button btnRegister, btnGoLogin;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_register, container, false);

        etUsername = view.findViewById(R.id.et_username);
        etPassword = view.findViewById(R.id.et_password);
        btnRegister = view.findViewById(R.id.btn_register);
        btnGoLogin = view.findViewById(R.id.btn_go_login);

        // 注册逻辑
        btnRegister.setOnClickListener(v -> handleRegister());

        // 已有账号 → 去登录
        btnGoLogin.setOnClickListener(v ->
                NavHostFragment.findNavController(this)
                        .navigate(R.id.action_register_to_login));

        return view;
    }

    private void handleRegister() {
        String username = etUsername.getText().toString().trim();
        String password = etPassword.getText().toString().trim();

        if (TextUtils.isEmpty(username)) {
            etUsername.setError("用户名不能为空");
            return;
        }
        if (TextUtils.isEmpty(password)) {
            etPassword.setError("密码不能为空");
            return;
        }

        // TODO: 这里可以保存账号到数据库或 SharedPreferences
        Toast.makeText(getContext(), "注册成功: " + username, Toast.LENGTH_SHORT).show();

        // 跳转到登录界面
        NavHostFragment.findNavController(this)
                .navigate(R.id.action_register_to_login);
    }
}
