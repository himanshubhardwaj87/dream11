package com.dream11.trial.journals.repository;

import com.dream11.trial.journals.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Long> {
}
