@echo off
setlocal enabledelayedexpansion

::输入等待时间
set "TIMEOUT_Print=1"

:: 设置超时时间（秒）
set TIMEOUT=5

:: 设置调试模式
set "DEBUG=false"

:: 文件完整情况
set "COMPLETENESS=true"

:: 获取脚本所在目录的绝对地址
set "SCRIPT_DIR=%~dp0%"

:: 设置Java Home路径
set "JAVA_HOME=%SCRIPT_DIR%jdk-21_windows-x64\jdk-21.0.4"

:: 设置Java路径
set "JAVA_PATH=%JAVA_HOME%\bin\java.exe"

:: 设置Jar文件路径
set "JAR_FILE=%SCRIPT_DIR%client.jar"

:: 设置配置文件路径
set "CONFIG_FILE=%SCRIPT_DIR%ESurfingDialerAccount.config"

set "TIMEOUT_Print_Command=timeout /t %TIMEOUT_Print% /nobreak >nul"

:: 检查文件是否完整
if not exist "%JAVA_PATH%" (
    set "COMPLETENESS=false"
    echo Java执行文件不存在。文件缺失。
    echo 请重新下载。
    %TIMEOUT_Print_Command%
)

if not exist "%JAR_FILE%" (
    set "COMPLETENESS=false"
    echo Jar文件不存在。文件缺失。
    echo 请重新下载。
    %TIMEOUT_Print_Command%
)

if "%COMPLETENESS%"=="false" (
    echo 文件不完整，无法继续执行。
    %TIMEOUT_Print_Command%
    goto END
)



:: 设置Java环境变量
set "PATH=%JAVA_HOME%\bin;%PATH%"

:: 读取配置文件内容
if exist "%CONFIG_FILE%" (
    for /f "tokens=1,* delims==" %%a in ('type "%CONFIG_FILE%"') do (
        set "value=%%b"
        if "%%a"=="USERNAME" set "USERNAME=!value!"
        if "%%a"=="PASSWORD" set "PASSWORD=!value!"
        if "%%a"=="USE_CONFIG" set "USE_CONFIG=!value!"
        if "%%a"=="NO_PROMPT" set "NO_PROMPT=!value!"
    )
	
	for /f "tokens=1,2 delims==" %%A in ('type %CONFIG_FILE%') do (
	if "%%A"=="USERNAME" set "USERNAME=%%B"
	if "%%A"=="PASSWORD" set "PASSWORD=%%B"
	if "%%A"=="USE_CONFIG" set "USE_CONFIG=%%B"
	if "%%A"=="NO_PROMPT" set "NO_PROMPT=%%B"
)
goto Check_Config
) else (
    set USERNAME=""
    set PASSWORD=""
    set USE_CONFIG=""
    set NO_PROMPT=""
    if "%DEBUG%"=="true" (
        echo 配置文件不存在，使用空置作为参数值。
        %TIMEOUT_Print_Command%
    )
)

:Check_Config
if "%DEBUG%"=="true" (
    echo 配置文件存在，读取到的用户名为: %USERNAME%
    echo 配置文件存在，读取到的密码为: %PASSWORD%
    echo 是否使用配置文件: %USE_CONFIG%
    echo 是否不再提示: %NO_PROMPT%
    %TIMEOUT_Print_Command%
)


if "%USE_CONFIG%"=="" (
    set USE_CONFIG=false
    if "%DEBUG%"=="true" (
        echo "USE_CONFIG"参数不合法，已重置为默认值"false"
        %TIMEOUT_Print_Command%
    )
) else (
    if not "%USE_CONFIG%"=="false" (
        if not "%USE_CONFIG%"=="true" (
            set USE_CONFIG=false
            if "%DEBUG%"=="true" (
                echo "USE_CONFIG"参数不合法，已重置为默认值"false"
                %TIMEOUT_Print_Command%
            )
        )
    )
)

if "%NO_PROMPT%"=="" (
    set NO_PROMPT=false
    if "%DEBUG%"=="true" (
        echo "NO_PROMPT"参数不合法，已重置为默认值"false"
        %TIMEOUT_Print_Command%
    )
) else (
    if not "%NO_PROMPT%"=="false" (
        if not "%NO_PROMPT%"=="true" (
            set USE_CONFIG=false
            if "%DEBUG%"=="true" (
                echo "NO_PROMPT"参数不合法，已重置为默认值"false"
                %TIMEOUT_Print_Command%
            )
        )
    )
)

if "%USE_CONFIG%"=="true" (
    if "%USERNAME%" == "" (
        set USE_CONFIG_CHECK= false
        if "%DEBUG%"=="true" (
            echo "USERNAME"参数不存在，无法设置"USE_CONFIG"成"true"
            %TIMEOUT_Print_Command%
        )
    )
)

if "%USE_CONFIG%"=="true" (
    if "%PASSWORD%" == "" (
        set USE_CONFIG_CHECK= false
        if "%DEBUG%"=="true" (
            echo "PASSWORD"参数不存在，无法设置"USE_CONFIG"成"true"
            %TIMEOUT_Print_Command%
        )
    )
)

if "%USE_CONFIG_CHECK%" == "false" (
    set USE_CONFIG=false
    if "%DEBUG%"=="true" (
        echo 配置文件检查不通过，无法设置"USE_CONFIG"成"true"
        %TIMEOUT_Print_Command%
    )
)

if "%USE_CONFIG%"=="true" (
    if "%NO_PROMPT%" == "false" (
        set NO_PROMPT = true
        if "%DEBUG%"=="true" (
            echo "USE_CONFIG"已设置成"true"，"NO_PROMPT"应该被设置成"true"
            %TIMEOUT_Print_Command%
        )
    )
)


:input_loop
if "%USE_CONFIG%"=="true" (
    if "%DEBUG%"=="true" (
        echo 使用配置文件中的账号密码。
        echo 若要取消不再显示设置界面，请将配置文件中的 "NO_PROMPT" 改为 "false"。
        echo 若要关闭默认使用配置文件的账号密码，请将配置文件中的 "USE_CONFIG" 改为 "false"。
        echo 配置文件路径: %CONFIG_FILE%
        %TIMEOUT_Print_Command%
    )
    set USERNAME=%USERNAME%
    set PASSWORD=%PASSWORD%
    goto execute_java
) else  (
    if "%DEBUG%"=="true" (
        echo 开始输入账号密码...
    )



:: 初始化变量
set NEW_USERNAME=""
set NEW_PASSWORD=""

if not "%USERNAME%" == "" (
    if not "%USERNAME%" == """" (
    echo 你上次使用的账号为: %USERNAME%
    %TIMEOUT_Print_Command%
    ) else (
        goto Account_Input
    )
) else (
    goto Account_Input
)

choice /t %TIMEOUT% /c YN /d Y /m "是否使用上次账号 "
if errorlevel 2 (
    if "%DEBUG%"=="true" (
        echo 用户选择不使用之前的账号，跳转至输入账号部分
    )
    goto Account_Input
) else (
    if "%DEBUG%"=="true" (
        echo 用户选择使用之前的账号，跳转至密码输部分
    )
    goto Password_Input
)

:Account_Input
set /p "NEW_USERNAME=请输入账号: "
if "%DEBUG%"=="true" (
    echo 你输入了：%NEW_USERNAME%
)

if "%NEW_USERNAME%"=="""" (
		if not "USERNAME"  == "" (
			if not "USERNAME"  == "" (
				echo 输入内容为空，将使用上次使用的账号: %USERNAME%
				goto Password_Input
			) else (
				echo 没有账号，脚本无法继续执行。
                %TIMEOUT_Print_Command%
				goto END
			)
		) else (
			echo 没有账号，脚本无法继续执行。
            %TIMEOUT_Print_Command%
			goto END
		)
	) else (
		set "USERNAME=%NEW_USERNAME%"
        if not "%DEBUG%"=="true" (
            goto Password_Input
            )
        )
	)

:Show_Username
echo 用户输入了新的账号: %USERNAME%


:Password_Input
if "%DEBUG%"=="true" (
	echo 用户名输入部分结束
	echo 最终用户名为：%USERNAME%
	)

if not "%PASSWORD%" == "" (
    if not "%PASSWORD%" == """" (
        if "%DEBUG%"=="true" (
            echo 你上次使用的密码为: %PASSWORD%
            )
    ) else (
        goto Password_Input_Two
    )
) else (
    goto Password_Input_Two
)

choice /t %TIMEOUT% /c YN /d Y /m "是否使用上次密码 "
if errorlevel 2 (
    if "%DEBUG%"=="true" (
        echo 用户选择不使用之前的密码，跳转至输入密码部分。
    )
    goto Password_Input_Two
) else (
    if "%DEBUG%"=="true" (
        echo 用户选择使用之前的密码
    )
    goto Settings_Page
)

:Password_Input_Two
set /p "NEW_PASSWORD=请输入密码: "
if "%DEBUG%"=="true" (
    echo 你输入了：%NEW_PASSWORD%
)



if "%NEW_PASSWORD%"=="""" (
		if not "PASSWORD"  == "" (
			if not "PASSWORD"  == "" (
				echo 输入内容为空，将使用上次使用的密码。
				if not "%PASSWORD%" == "" (
					if "%DEBUG%"=="true" (
						echo 你上次使用的密码为: %PASSWORD%
					)
				)
				goto Settings_Page
			) else (
				echo 没有密码，脚本无法继续执行。
                %TIMEOUT_Print_Command%
				goto END
			)
		) else (
			echo 没有密码，脚本无法继续执行。
            %TIMEOUT_Print_Command%
			goto END
		)
	) else (
		set "PASSWORD=%NEW_PASSWORD%"
        if not "%DEBUG%"=="true" (
            goto Settings_Page
            )
        )
	


:Show_Password
echo 用户输入了新的密码: %PASSWORD%




:Settings_Page
	if "%DEBUG%"=="true" (
		echo 密码输入部分结束
		echo 最终密码为：%PASSWORD%
		)
    if "%NO_PROMPT%" == "true" (
        echo.
        echo 已设置不再弹出设置页面，
        echo 若要取消不再显示设置界面，请将配置文件中的 "NO_PROMPT" 改为 "false"。
        echo 配置文件路径: %CONFIG_FILE%
        echo.
        %TIMEOUT_Print_Command%
		goto NO_PROMPT_Two
    ) else (
        :: 初始化变量
        set USE_CONFIG_INPUT = ""
        set NO_PROMPT_INPUT = ""
        :: 弹出提示要求用户是否默认使用配置文件中的账号密码
		if "%DEBUG%"=="true" (
			echo 当前USE_CONFIG参数：%USE_CONFIG%
		)
        choice /t %TIMEOUT% /c YN /d Y /m "是否默认使用配置文件中的账号密码? (Y/N，默认Y): "
        if errorlevel 2 (
            goto Set_USE_CONFIG_False
        ) else (
            goto Set_USE_CONFIG_True
        )

        :Set_USE_CONFIG_False
        set USE_CONFIG=false
        if "%DEBUG%" == "true" (
            echo 已取消设置默认使用配置文件中的账号密码。
            %TIMEOUT_Print_Command%
            if "%DEBUG%"=="true" (
                echo 当前USE_CONFIG参数：%USE_CONFIG%
                )
			goto NO_PROMPT_One
        )

        :Set_USE_CONFIG_True
        set USE_CONFIG=true
        echo 已设置默认使用配置文件中的账号密码。
        %TIMEOUT_Print_Command%
        if "%DEBUG%"=="true" (
            echo 当前USE_CONFIG参数：%USE_CONFIG%
            )
		goto NO_PROMPT_One
        
		
		:NO_PROMPT_One
        :: 弹出提示要求用户是否不再弹出此设置界面
		if "%DEBUG%"=="true" (
			echo NO_PROMPT：%NO_PROMPT%
		)
        choice /t %TIMEOUT% /c YN /d N /m "是否不再弹出此设置界面? (Y/N，默认N): "
        if errorlevel 2 (
			goto Set_NO_PROMPT_False
        ) else (
			goto Set_NO_PROMPT_True
        )
		
        :Set_NO_PROMPT_False
        set NO_PROMPT=false
        if "%DEBUG%" == "true" (
            echo 已取消设置不再弹出此设置界面。
            %TIMEOUT_Print_Command%
            if "%DEBUG%"=="true" (
                echo 当前NO_PROMPT参数：%NO_PROMPT%
                )
			goto NO_PROMPT_Two
        )

        :Set_NO_PROMPT_True
        set NO_PROMPT=true
        if "%DEBUG%" == "true" (
            echo 已设置不再弹出此设置界面。
            %TIMEOUT_Print_Command%
            if "%DEBUG%"=="true" (
                echo 当前NO_PROMPT参数：%NO_PROMPT%
                )
			goto NO_PROMPT_Two
        )
		
		:NO_PROMPT_Two
        :: 将获取到的账号密码和设置储存到config中
        if not exist "%CONFIG_FILE%" (
            type nul > "%CONFIG_FILE%"
            if "%DEBUG%"=="true" (
                echo 配置文件不存在，已创建。
                %TIMEOUT_Print_Command%
            )
        ) else (
            del "%CONFIG_FILE%"
            type nul > "%CONFIG_FILE%"
            if "%DEBUG%"=="true" (
                echo 配置文件存在，已清空重建。
                %TIMEOUT_Print_Command%
            )
        )
		if "%DEBUG%"=="true" (
			echo 当前USERNAME参数：%USERNAME%
		)
		if "%DEBUG%"=="true" (
			echo 当前PASSWORD参数：%PASSWORD%
		)
		if "%DEBUG%"=="true" (
			echo 当前USE_CONFIG参数：%USE_CONFIG%
		)
		if "%DEBUG%"=="true" (
			echo 当前NO_PROMPT参数：%NO_PROMPT%
		)
        echo USERNAME=%USERNAME%> "%CONFIG_FILE%"
        echo PASSWORD=%PASSWORD%>> "%CONFIG_FILE%"
        echo USE_CONFIG=%USE_CONFIG%>> "%CONFIG_FILE%"
        echo NO_PROMPT=%NO_PROMPT%>> "%CONFIG_FILE%"
        if "%DEBUG%"=="true" (
            echo 账号密码和设置已保存到配置文件。
        )
    )

:execute_java
:: 执行Java程序
if "%DEBUG%"=="true" (
    echo 执行Java程序，参数为: "%JAVA_PATH%" -jar "%JAR_FILE%" -u "%USERNAME%" -p "%PASSWORD%"
)
"%JAVA_PATH%" -jar "%JAR_FILE%" -u "%USERNAME%" -p "%PASSWORD%"
if "%DEBUG%"=="true" (
    echo Java程序执行完毕。
)

:END
endlocal
