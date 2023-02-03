package net.bedone.devopstasks.repo;

import net.bedone.devopstasks.db_object.Movies;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ExampleRepo extends JpaRepository<Movies, Long> {

}
