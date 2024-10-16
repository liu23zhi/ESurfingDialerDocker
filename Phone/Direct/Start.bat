@echo off
setlocal enabledelayedexpansion

::����ȴ�ʱ��
set "TIMEOUT_Print=1"

:: ���ó�ʱʱ�䣨�룩
set TIMEOUT=5

:: ���õ���ģʽ
set "DEBUG=true"

:: �ļ��������
set "COMPLETENESS=true"

:: ��ȡ�ű�����Ŀ¼�ľ��Ե�ַ
set "SCRIPT_DIR=%~dp0%"

:: ����Java Home·��
set "JAVA_HOME=%SCRIPT_DIR%jdk-21_windows-x64"

:: ����Java·��
set "JAVA_PATH=%JAVA_HOME%\bin\java.exe"

:: ����Jar�ļ�·��
set "JAR_FILE=%SCRIPT_DIR%client.jar"

:: ���������ļ�·��
set "CONFIG_FILE=%SCRIPT_DIR%ESurfingDialerAccount.config"

set "TIMEOUT_Print_Command=timeout /t %TIMEOUT_Print% /nobreak >nul"

:: ����ļ��Ƿ�����
if not exist "%JAVA_PATH%" (
    set "COMPLETENESS=false"
    echo Javaִ���ļ������ڡ��ļ�ȱʧ��
    echo ���������ء�
    %TIMEOUT_Print_Command%
)

if not exist "%JAR_FILE%" (
    set "COMPLETENESS=false"
    echo Jar�ļ������ڡ��ļ�ȱʧ��
    echo ���������ء�
    %TIMEOUT_Print_Command%
)

if "%COMPLETENESS%"=="false" (
    echo �ļ����������޷�����ִ�С�
    %TIMEOUT_Print_Command%
    goto END
)



:: ����Java��������
set "PATH=%JAVA_HOME%\bin;%PATH%"

:: ��ȡ�����ļ�����
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
        echo �����ļ������ڣ�ʹ�ÿ�����Ϊ����ֵ��
        %TIMEOUT_Print_Command%
    )
)

:Check_Config
if "%DEBUG%"=="true" (
    echo �����ļ����ڣ���ȡ�����û���Ϊ: %USERNAME%
    echo �����ļ����ڣ���ȡ��������Ϊ: %PASSWORD%
    echo �Ƿ�ʹ�������ļ�: %USE_CONFIG%
    echo �Ƿ�����ʾ: %NO_PROMPT%
    %TIMEOUT_Print_Command%
)


if "%USE_CONFIG%"=="" (
    set USE_CONFIG=false
    if "%DEBUG%"=="true" (
        echo "USE_CONFIG"�������Ϸ���������ΪĬ��ֵ"false"
        %TIMEOUT_Print_Command%
    )
) else (
    if not "%USE_CONFIG%"=="false" (
        if not "%USE_CONFIG%"=="true" (
            set USE_CONFIG=false
            if "%DEBUG%"=="true" (
                echo "USE_CONFIG"�������Ϸ���������ΪĬ��ֵ"false"
                %TIMEOUT_Print_Command%
            )
        )
    )
)

if "%NO_PROMPT%"=="" (
    set NO_PROMPT=false
    if "%DEBUG%"=="true" (
        echo "NO_PROMPT"�������Ϸ���������ΪĬ��ֵ"false"
        %TIMEOUT_Print_Command%
    )
) else (
    if not "%NO_PROMPT%"=="false" (
        if not "%NO_PROMPT%"=="true" (
            set USE_CONFIG=false
            if "%DEBUG%"=="true" (
                echo "NO_PROMPT"�������Ϸ���������ΪĬ��ֵ"false"
                %TIMEOUT_Print_Command%
            )
        )
    )
)

if "%USE_CONFIG%"=="true" (
    if "%USERNAME%" == "" (
        set USE_CONFIG_CHECK= false
        if "%DEBUG%"=="true" (
            echo "USERNAME"���������ڣ��޷�����"USE_CONFIG"��"true"
            %TIMEOUT_Print_Command%
        )
    )
)

if "%USE_CONFIG%"=="true" (
    if "%PASSWORD%" == "" (
        set USE_CONFIG_CHECK= false
        if "%DEBUG%"=="true" (
            echo "PASSWORD"���������ڣ��޷�����"USE_CONFIG"��"true"
            %TIMEOUT_Print_Command%
        )
    )
)

if "%USE_CONFIG_CHECK%" == "false" (
    set USE_CONFIG=false
    if "%DEBUG%"=="true" (
        echo �����ļ���鲻ͨ�����޷�����"USE_CONFIG"��"true"
        %TIMEOUT_Print_Command%
    )
)

if "%USE_CONFIG%"=="true" (
    if "%NO_PROMPT%" == "false" (
        set NO_PROMPT = true
        if "%DEBUG%"=="true" (
            echo "USE_CONFIG"�����ó�"true"��"NO_PROMPT"Ӧ�ñ����ó�"true"
            %TIMEOUT_Print_Command%
        )
    )
)


:input_loop
if "%USE_CONFIG%"=="true" (
    if "%DEBUG%"=="true" (
        echo ʹ�������ļ��е��˺����롣
        echo ��Ҫȡ��������ʾ���ý��棬�뽫�����ļ��е� "NO_PROMPT" ��Ϊ "false"��
        echo ��Ҫ�ر�Ĭ��ʹ�������ļ����˺����룬�뽫�����ļ��е� "USE_CONFIG" ��Ϊ "false"��
        echo �����ļ�·��: %CONFIG_FILE%
        %TIMEOUT_Print_Command%
    )
    set USERNAME=%USERNAME%
    set PASSWORD=%PASSWORD%
    goto execute_java
) else  (
    if "%DEBUG%"=="true" (
        echo ��ʼ�����˺�����...
    )



:: ��ʼ������
set NEW_USERNAME=""
set NEW_PASSWORD=""

if not "%USERNAME%" == "" (
    if not "%USERNAME%" == """" (
    echo ���ϴ�ʹ�õ��˺�Ϊ: %USERNAME%
    %TIMEOUT_Print_Command%
    ) else (
        goto Account_Input
    )
) else (
    goto Account_Input
)

choice /t %TIMEOUT% /c YN /d Y /m "�Ƿ�ʹ���ϴ��˺� "
if errorlevel 2 (
    if "%DEBUG%"=="true" (
        echo �û�ѡ��ʹ��֮ǰ���˺ţ���ת�������˺Ų���
    )
    goto Account_Input
) else (
    if "%DEBUG%"=="true" (
        echo �û�ѡ��ʹ��֮ǰ���˺ţ���ת�������䲿��
    )
    goto Password_Input
)

:Account_Input
set /p "NEW_USERNAME=�������˺�: "
if "%DEBUG%"=="true" (
    echo �������ˣ�%NEW_USERNAME%
)

if "%NEW_USERNAME%"=="""" (
		if not "USERNAME"  == "" (
			if not "USERNAME"  == "" (
				echo ��������Ϊ�գ���ʹ���ϴ�ʹ�õ��˺�: %USERNAME%
				goto Password_Input
			) else (
				echo û���˺ţ��ű��޷�����ִ�С�
                %TIMEOUT_Print_Command%
				goto END
			)
		) else (
			echo û���˺ţ��ű��޷�����ִ�С�
            %TIMEOUT_Print_Command%
			goto END
		)
	) else (
		:: �ж�����ĵ�һ�������һ���ַ��Ƿ�ͬʱΪ˫���ţ�����Ӧ��ȥ��
		:: if "%NEW_USERNAME:~0,1%"=="""" if "%NEW_USERNAME:~-1%"=="""" (
		:: 	set "USERNAME=!NEW_USERNAME:~1,-1!"
		:: )
		
		:: �ж�����ĵ�һ�������һ���ַ��Ƿ�ͬʱΪ�����ţ�����Ӧ��ȥ��
		:: if "%NEW_USERNAME:~0,1%"=="'" if "%NEW_USERNAME:~-1%"=="'" (
		:: 	set "USERNAME=!NEW_USERNAME:~1,-1!"
		:: )
		
		set "USERNAME=%NEW_USERNAME%"
        if not "%DEBUG%"=="true" (
            goto Password_Input
            )
        )
	)

:Show_Username
echo �û��������µ��˺�: %USERNAME%


:Password_Input
if "%DEBUG%"=="true" (
	echo �û������벿�ֽ���
	echo �����û���Ϊ��%USERNAME%
	)

if not "%PASSWORD%" == "" (
    if not "%PASSWORD%" == """" (
        if "%DEBUG%"=="true" (
            echo ���ϴ�ʹ�õ�����Ϊ: %PASSWORD%
            )
    ) else (
        goto Password_Input_Two
    )
) else (
    goto Password_Input_Two
)

choice /t %TIMEOUT% /c YN /d Y /m "�Ƿ�ʹ���ϴ����� "
if errorlevel 2 (
    if "%DEBUG%"=="true" (
        echo �û�ѡ��ʹ��֮ǰ�����룬��ת���������벿�֡�
    )
    goto Password_Input_Two
) else (
    if "%DEBUG%"=="true" (
        echo �û�ѡ��ʹ��֮ǰ������
    )
    goto Settings_Page
)

:Password_Input_Two
set /p "NEW_PASSWORD=����������: "
if "%DEBUG%"=="true" (
    echo �������ˣ�%NEW_PASSWORD%
)



if "%NEW_PASSWORD%"=="""" (
		if not "PASSWORD"  == "" (
			if not "PASSWORD"  == "" (
				echo ��������Ϊ�գ���ʹ���ϴ�ʹ�õ����롣
				if not "%PASSWORD%" == "" (
					if "%DEBUG%"=="true" (
						echo ���ϴ�ʹ�õ�����Ϊ: %PASSWORD%
					)
				)
				goto Settings_Page
			) else (
				echo û�����룬�ű��޷�����ִ�С�
                %TIMEOUT_Print_Command%
				goto END
			)
		) else (
			echo û�����룬�ű��޷�����ִ�С�
            %TIMEOUT_Print_Command%
			goto END
		)
	) else (
		:: �ж�����ĵ�һ�������һ���ַ��Ƿ�ͬʱΪ˫���ţ�����Ӧ��ȥ��
		:: if "%NEW_PASSWORD:~0,1%"=="""" if "%NEW_PASSWORD:~-1%"=="""" (
		:: 	set "PASSWORD=!NEW_PASSWORD:~1,-1!"
		:: )
		
		:: �ж�����ĵ�һ�������һ���ַ��Ƿ�ͬʱΪ�����ţ�����Ӧ��ȥ��
		:: if "%NEW_PASSWORD:~0,1%"=="'" if "%NEW_PASSWORD:~-1%"=="'" (
		:: 	set "PASSWORD=!NEW_PASSWORD:~1,-1!"
		:: )
		
		set "PASSWORD=%NEW_PASSWORD%"
        if not "%DEBUG%"=="true" (
            goto Settings_Page
            )
        )
	


:Show_Password
echo �û��������µ�����: %PASSWORD%




:Settings_Page
	if "%DEBUG%"=="true" (
		echo �������벿�ֽ���
		echo ��������Ϊ��%PASSWORD%
		)
    if "%NO_PROMPT%" == "true" (
        echo.
        echo �����ò��ٵ�������ҳ�棬
        echo ��Ҫȡ��������ʾ���ý��棬�뽫�����ļ��е� "NO_PROMPT" ��Ϊ "false"��
        echo �����ļ�·��: %CONFIG_FILE%
        echo.
        %TIMEOUT_Print_Command%
		goto NO_PROMPT_Two
    ) else (
        :: ��ʼ������
        set USE_CONFIG_INPUT = ""
        set NO_PROMPT_INPUT = ""
        :: ������ʾҪ���û��Ƿ�Ĭ��ʹ�������ļ��е��˺�����
		if "%DEBUG%"=="true" (
			echo ��ǰUSE_CONFIG������%USE_CONFIG%
		)
        choice /t %TIMEOUT% /c YN /d Y /m "�Ƿ�Ĭ��ʹ�������ļ��е��˺�����? (Y/N��Ĭ��Y): "
        if errorlevel 2 (
            goto Set_USE_CONFIG_False
        ) else (
            goto Set_USE_CONFIG_True
        )

        :Set_USE_CONFIG_False
        set USE_CONFIG=false
        if "%DEBUG%" == "true" (
            echo ��ȡ������Ĭ��ʹ�������ļ��е��˺����롣
            %TIMEOUT_Print_Command%
            if "%DEBUG%"=="true" (
                echo ��ǰUSE_CONFIG������%USE_CONFIG%
                )
			goto NO_PROMPT_One
        )

        :Set_USE_CONFIG_True
        set USE_CONFIG=true
        echo ������Ĭ��ʹ�������ļ��е��˺����롣
        %TIMEOUT_Print_Command%
        if "%DEBUG%"=="true" (
            echo ��ǰUSE_CONFIG������%USE_CONFIG%
            )
		goto NO_PROMPT_One
        
		
		:NO_PROMPT_One
        :: ������ʾҪ���û��Ƿ��ٵ��������ý���
		if "%DEBUG%"=="true" (
			echo NO_PROMPT��%NO_PROMPT%
		)
        choice /t %TIMEOUT% /c YN /d N /m "�Ƿ��ٵ��������ý���? (Y/N��Ĭ��N): "
        if errorlevel 2 (
			goto Set_NO_PROMPT_False
        ) else (
			goto Set_NO_PROMPT_True
        )
		
        :Set_NO_PROMPT_False
        set NO_PROMPT=false
        if "%DEBUG%" == "true" (
            echo ��ȡ�����ò��ٵ��������ý��档
            %TIMEOUT_Print_Command%
            if "%DEBUG%"=="true" (
                echo ��ǰNO_PROMPT������%NO_PROMPT%
                )
			goto NO_PROMPT_Two
        )

        :Set_NO_PROMPT_True
        set NO_PROMPT=true
        if "%DEBUG%" == "true" (
            echo �����ò��ٵ��������ý��档
            %TIMEOUT_Print_Command%
            if "%DEBUG%"=="true" (
                echo ��ǰNO_PROMPT������%NO_PROMPT%
                )
			goto NO_PROMPT_Two
        )
		
		:NO_PROMPT_Two
        :: ����ȡ�����˺���������ô��浽config��
        if not exist "%CONFIG_FILE%" (
            type nul > "%CONFIG_FILE%"
            if "%DEBUG%"=="true" (
                echo �����ļ������ڣ��Ѵ�����
                %TIMEOUT_Print_Command%
            )
        ) else (
            del "%CONFIG_FILE%"
            type nul > "%CONFIG_FILE%"
            if "%DEBUG%"=="true" (
                echo �����ļ����ڣ�������ؽ���
                %TIMEOUT_Print_Command%
            )
        )
		if "%DEBUG%"=="true" (
			echo ��ǰUSERNAME������%USERNAME%
		)
		if "%DEBUG%"=="true" (
			echo ��ǰPASSWORD������%PASSWORD%
		)
		if "%DEBUG%"=="true" (
			echo ��ǰUSE_CONFIG������%USE_CONFIG%
		)
		if "%DEBUG%"=="true" (
			echo ��ǰNO_PROMPT������%NO_PROMPT%
		)
        echo USERNAME=%USERNAME%> "%CONFIG_FILE%"
        echo PASSWORD=%PASSWORD%>> "%CONFIG_FILE%"
        echo USE_CONFIG=%USE_CONFIG%>> "%CONFIG_FILE%"
        echo NO_PROMPT=%NO_PROMPT%>> "%CONFIG_FILE%"
        if "%DEBUG%"=="true" (
            echo �˺�����������ѱ��浽�����ļ���
        )
    )

:execute_java
:: ִ��Java����
if "%DEBUG%"=="true" (
    echo ִ��Java���򣬲���Ϊ: "%JAVA_PATH%" -jar "%JAR_FILE%" -u %USERNAME% -p %PASSWORD%
)
"%JAVA_PATH%" -jar "%JAR_FILE%" -u %USERNAME% -p %PASSWORD%
if "%DEBUG%"=="true" (
    echo Java����ִ����ϡ�
)

:END
endlocal
