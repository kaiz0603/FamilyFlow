package com.example.familyflow.ui.auth;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.RadioButton;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.Navigation;

import com.example.familyflow.R;

public class LoginFragment extends Fragment {

    private RadioButton rbParent, rbChild;
    private Button btnLogin;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_login, container, false);

        rbParent = root.findViewById(R.id.rb_parent);
        rbChild = root.findViewById(R.id.rb_child);
        btnLogin = root.findViewById(R.id.btn_login);

        btnLogin.setOnClickListener(v -> {
            String role = rbParent.isChecked() ? "parent" : "child";
            Bundle bundle = new Bundle();
            bundle.putString("role", role);
            Navigation.findNavController(v).navigate(R.id.action_login_to_firstUse, bundle);
        });

        return root;
    }
}
