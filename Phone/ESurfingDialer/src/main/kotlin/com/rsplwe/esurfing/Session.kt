package com.rsplwe.esurfing

import com.rsplwe.esurfing.cipher.CipherFactory
import com.rsplwe.esurfing.cipher.CipherInterface
import org.apache.log4j.Logger
import java.io.File

object Session {

    private val logger: Logger = Logger.getLogger(Session::class.java)
    private var initialized = false
    private lateinit var cipher: CipherInterface

    fun initialize(zsm: ByteArray) {
        logger.info("Initializing Session...")
        initialized = load(zsm)
    }

    fun isInitialized(): Boolean {
        return initialized
    }

    private fun load(zsm: ByteArray): Boolean {
        try {
            if (zsm.size < 4) {
                logger.error("Invalid zsm header")
                return false
            }
            val header = zsm.sliceArray(0 until 3).decodeToString()
            val keyLen = zsm[3]
            var pos = 4
            if (pos + keyLen > zsm.size) {
                logger.error("Invalid key length")
                return false
            }
            val key = zsm.sliceArray(pos until pos + keyLen).decodeToString()
            pos += keyLen
            if (pos >= zsm.size) {
                logger.error("Invalid algo id length")
                return false
            }
            val algoIdLen = zsm[pos]
            pos += 1
            if (pos + algoIdLen > zsm.size) {
                logger.error("Invalid algo id")
                return false
            }
            val algoId = zsm.sliceArray(pos until pos + algoIdLen).decodeToString()

            cipher = CipherFactory.getInstance(algoId)
            States.algoId = algoId
            logger.info("Type: $header")
            logger.info("Algo Id: $algoId")
            logger.info("Key: $key")
        } catch (e: Throwable) {
            logger.error(e.message)
            saveBytesToFile("algo_dump_${System.currentTimeMillis()}.bin", zsm)
            return false
        }
        return true
    }

    fun decrypt(hex: String): String {
        return cipher.decrypt(hex)
    }

    fun encrypt(text: String): String {
        return cipher.encrypt(text)
    }

    fun free() {
        initialized = false
    }

    private fun saveBytesToFile(fileName: String, data: ByteArray) {
        val file = File(fileName)
        file.writeBytes(data)
        logger.info("Please submit issue to https://github.com/Rsplwe/ESurfingDialer/issues and attach the file ${file.absolutePath}")
    }
}