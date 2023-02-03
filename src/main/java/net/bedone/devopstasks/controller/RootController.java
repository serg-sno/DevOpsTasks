package net.bedone.devopstasks.controller;

import net.bedone.devopstasks.db_object.Movies;
import net.bedone.devopstasks.repo.ExampleRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@SuppressWarnings("SpringJavaAutowiredFieldsWarningInspection")
@Controller
public class RootController {
    @Autowired
    ExampleRepo exampleRepo;
    @Value("${spring.datasource.url}")
    private String databaseUrl;
    @Value("${spring.datasource.username}")
    private String databaseUsername;
    @GetMapping("/")
    @ResponseBody
    public String GetMain() {
        StringBuilder s = new StringBuilder(String.format("""
                <H1>This is a simple Java Spring boot application</H1>
                <H2>Database connection parameters:</H2>
                Url = <b>%s</b><br>
                Username = <b>%s</b><br>
                Password = <b>******</b>
                <H2>Top 5 movies according to IMDB:</H2>
                <table border='1' cellpadding='5'>
                  <tr>
                    <th>Id</th>
                    <th>Title</th>
                    <th>Year</th>
                    <th>Director</th>
                  </tr>
                """, databaseUrl, databaseUsername));
        for (Movies e :
                exampleRepo.findAll()) {
            s.append(String.format(
                    """
                              <tr>
                                <td>%s</td>
                                <td>%s</td>
                                <td>%d</td>
                                <td>%s</td>
                              </tr>
                            """, e.getId(), e.getTitle(), e.getYear(), e.getDirector()));
        }
        s.append("</table><br>").append("<p>If you see the movie list, then the database connection has been established<p>");

        return s.toString();
    }
}
