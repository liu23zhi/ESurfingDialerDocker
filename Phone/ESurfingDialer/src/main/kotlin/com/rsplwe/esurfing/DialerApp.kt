package com.rsplwe.esurfing

import com.rsplwe.esurfing.States.isRunning
import org.apache.commons.cli.*
import org.apache.commons.cli.Options
import org.apache.log4j.Logger
import kotlin.system.exitProcess

object DialerApp {

    private val logger: Logger = Logger.getLogger(DialerApp::class.java)

    @JvmStatic
    fun main(args: Array<String>) {
        val options = Options()
        val loginUser = Option.builder("u").longOpt("user")
            .argName("user")
            .hasArg()
            .required(true)
            .desc("Login User (Phone Number or Other)").build()
        val loginPassword = Option.builder("p").longOpt("password")
            .argName("password")
            .hasArg()
            .required(true)
            .desc("Login User Password").build()
        val smsCode = Option.builder("s").longOpt("sms")
            .argName("sms")
            .hasArg()
            .required(false)
            .desc("Pre-enter verification code").build()
        options.addOption(loginUser)
        options.addOption(loginPassword)
        options.addOption(smsCode)

        val cmd: CommandLine
        val parser: CommandLineParser = DefaultParser()
        val helper = HelpFormatter()

        try {
            cmd = parser.parse(options, args)
        } catch (e: ParseException) {
            logger.error(e.message)
            helper.printHelp("ESurfingDialer", options)
            exitProcess(1)
        }

        val client = Client(
            Options(
                cmd.getOptionValue("user"),
                cmd.getOptionValue("password"),
                cmd.getOptionValue("sms") ?: "",
            )
        )

        Runtime.getRuntime().addShutdownHook(object : Thread() {
            override fun run() {
                try {
                    if (isRunning) {
                        isRunning = false
                    }
                    if (Session.isInitialized()) {
                        if (States.isLogged){
                            client.term()
                        }
                        Session.free()
                    }
                    println("Shutting down...")
                } catch (e: InterruptedException) {
                    currentThread().interrupt()
                    e.printStackTrace()
                }
            }
        })
        States.refreshStates()
        client.run()
    }
}