package org.jw.bot.controller;

import lombok.extern.java.Log;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@RestController
@EnableWebMvc
@Log
public class BotController {

    @RequestMapping(path = "/bot", method = RequestMethod.POST)
    public void postBotServer() {
        log.info("Line is posting to my bot server");

    }
}
