package com.rsplwe.esurfing.network

import com.rsplwe.esurfing.Constants
import com.rsplwe.esurfing.States
import okhttp3.Interceptor
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import okhttp3.ResponseBody
import org.apache.commons.codec.digest.DigestUtils
import org.apache.log4j.Logger
import java.util.concurrent.TimeUnit

class RedirectInterceptor : Interceptor {

    private val logger: Logger = Logger.getLogger(RedirectInterceptor::class.java)

    override fun intercept(chain: Interceptor.Chain): Response {
        var request = chain.request()
        var response = chain.proceed(request)
        var redirectCount = 0

        while (response.isRedirect && redirectCount++ < 5) {
            logger.info("Redirect #${redirectCount}")
            logger.info("Url: ${request.url}")
            logger.info("Response Code: ${response.code}")

            val area = response.header("area")
            val schoolId = response.header("schoolid")
            val domain = response.header("domain")

            if (!area.isNullOrBlank()) {
                States.area = area
                logger.info("Add Header -> CDC-Area: ${States.area}")
            }
            if (!schoolId.isNullOrBlank()) {
                States.schoolId = schoolId
                logger.info("Add Header -> CDC-SchoolId: ${States.schoolId}")
            }
            if (!domain.isNullOrBlank()) {
                States.domain = domain
                logger.info("Add Header -> CDC-Domain: ${States.domain}")
            }

            val location = response.header("Location") ?: break

            response.close()
            request = request.newBuilder().url(location).build()
            response = chain.proceed(request)
        }
        return response
    }
}

fun createHttpClient(): OkHttpClient {
    val builder = OkHttpClient.Builder()
        .addInterceptor(RedirectInterceptor())
        .followRedirects(false)
        .followSslRedirects(false)
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .writeTimeout(10, TimeUnit.SECONDS)
    return builder.build()
}

val apiClient = createHttpClient()

fun post(url: String, data: String, extraHeaders: HashMap<String, String> = HashMap()): NetResult<ResponseBody> {
    val type = "application/x-www-form-urlencoded".toMediaTypeOrNull()
    val body = data.toRequestBody(type)
    val request = Request.Builder()
        .removeHeader("User-Agent")
        .addHeader("User-Agent", Constants.USER_AGENT)
        .addHeader("Accept", Constants.REQUEST_ACCEPT)
        .addHeader("CDC-Checksum", DigestUtils.md5Hex(data))
        .addHeader("Client-ID", States.clientId)
        .addHeader("Algo-ID", States.algoId)
        .url(url)
        .post(body)

    extraHeaders.forEach {
        request.addHeader(it.key, it.value)
    }
    if (States.schoolId.isNotEmpty()) {
        request.addHeader("CDC-SchoolId", States.schoolId)
    }
    if (States.domain.isNotEmpty()) {
        request.addHeader("CDC-Domain", States.domain)
    }
    if (States.area.isNotEmpty()) {
        request.addHeader("CDC-Area", States.area)
    }

    return try {
        val response = apiClient.newCall(request.build()).execute()
        NetResult.Success(response.body!!)
    } catch (e: Throwable) {
        NetResult.Error(e.stackTraceToString())
    }
}