package com.example.familyflow.model;

import java.util.List;

public class Question {
    public int id;
    public String question;
    public List<Option> options;

    public static class Option {
        public String text;
        public int[] scores; // [民主, 独断, 宽松, 忽视]
    }
}
