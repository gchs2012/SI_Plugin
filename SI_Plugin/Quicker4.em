macro AutoExpand()
{
    /* 配置信息 */
    /* get window, sel, and buffer handles */
    hwnd = GetCurrentWnd()
    if (hwnd == 0) stop

    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)

    language = GetReg(LANGUAGE)
    if (language != 1)
    {
        language = 0
    }

    /* 取得用户名 */
    szName = GetReg(MYNAME)
    if (strlen(szName) == 0)
    {
        if (language == 1)
        {
            szName = Ask("Please input your name:")
        }
        else
        {
            szName = Ask("请输入你的名字:")
        }

        if (szName == "#")
        {
            SetReg("MYNAME", "Mr.Zhang")
        }
        else
        {
            SetReg("MYNAME", szName)
        }
    }

    /* 获取行选择（插入点）已打开 */
    szLine = GetBufLine(hbuf, sel.lnFirst);

    /* 解析插入点左侧的单词 */
    wordinfo = GetWordLeftOfIch(sel.ichFirst, szLine)
    ln = sel.lnFirst;
    chTab = CharFromAscii(9)

    ich = 0
    chSpace = CharFromAscii(32);
    while (szLine[ich] == chSpace || szLine[ich] == chTab)
    {
        ich = ich + 1
    }
    szLine1 = strmid(szLine, 0, ich)
    szLine  = strmid(szLine, 0, ich) # "    "

    sel.lnFirst  = sel.lnLast
    sel.ichFirst = wordinfo.ich
    sel.ichLim   = wordinfo.ich

    /* 自动完成简化命令的匹配显示 */
    wordinfo.szWord = RestoreCommand(hbuf, wordinfo.szWord)
    sel = GetWndSel(hwnd)
    if (wordinfo.szWord == "config" || wordinfo.szWord == "co")
    {
        /* 配置命令 */
        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "")
        SetSystemConfig(language)
        return
    }
    else if (wordinfo.szWord == "pn")
    {
        /* 问题单号 */
        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "")
        AddPromblemNo()
        return
    }
    else if (wordinfo.szWord == "hi")
    {
        /* 修改历史记录更新 */
        return
    }
    else if (wordinfo.szWord == "abg")
    {
        /* 添加代码记录 */
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd, sel)
        InsertReviseAction("Added")
        PutBufLine(hbuf, ln + 1, szLine1)
        SetBufIns(hwnd, ln + 1, sel.ichFirst)
        return
    }
    else if (wordinfo.szWord == "dbg")
    {
        /* 删除代码记录 */
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd, sel)
        InsertReviseAction("Deleted")
        PutBufLine(hbuf, ln + 1, szLine1)
        SetBufIns(hwnd, ln + 1, sel.ichFirst)
        return
    }
    else if (wordinfo.szWord == "mbg")
    {
        /* 修改代码记录 */
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd, sel)
        InsertReviseAction("Modified")
        PutBufLine(hbuf, ln + 1, szLine1)
        SetBufIns(hwnd, ln + 1, sel.ichFirst)
        return
    }
    else if (wordinfo.szWord == "name")
    {
        /* 修改用户名 */
        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "")
        if (language == 1)
        {
            szName = Ask("Please input your name:")
        }
        else
        {
            szName = Ask("请输入你的名字:")	
        }

        if (szName == "#")
        {
            SetReg("MYNAME", "Mr.Zhang")
        }
        else
        {
            SetReg("MYNAME", szName)
        }
        return
    }
    else if (wordinfo.szWord == "company")
    {
        /* 修改公司名称 */
        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "")
        if (language == 1)
        {
            szCompany = Ask("Please input company name:")
        }
        else
        {
            szCompany = Ask("请输入公司名称：")
        }

        if (szCompany == "#")
        {
            SetReg("COMPANY", "xxx Co.xxx, Ltd.")
        }
        else
        {
            SetReg(COMPANY, szName)
        }
        return
    }

    if (language == 1)
    {
        /* 英文处理流程 */
    }
    else
    {
        /* 中文处理流程 */
        ExpandProcCN(szName, wordinfo, szLine, szLine1, ln, sel)
    }
}

macro GetWordLeftOfIch(ich, sz)
{
    wordinfo = ""
    chTab = CharFromAscii(9)

    /* scan backwords over white space, if any */
    ich = ich - 1;
    if (ich >= 0)
    {
        while (sz[ich] == " " || sz[ich] == chTab)
        {
            ich = ich - 1;
            if (ich < 0) break;
        }
    }

    /* scan backwords to start of word */
    ichLim = ich + 1;
    asciiA = AsciiFromChar("A")
    asciiZ = AsciiFromChar("Z")
    while (ich >= 0)
    {
        ch = toupper(sz[ich])
        asciiCh = AsciiFromChar(ch)

        /* 只提取字符和 '#' '{' '/' '*' 作为命令 */
        if ((asciiCh < asciiA || asciiCh > asciiZ) 
            && !IsNumber(ch)
            && (ch != "#" && ch != "{" && ch != "/" && ch != "*"))
        {
            break;
        }
        ich = ich - 1;
    }

    ich = ich + 1
    wordinfo.szWord = strmid(sz, ich, ichLim)
    wordinfo.ich = ich
    wordinfo.ichLim = ichLim;

    return wordinfo
}

macro CreateBlankString(iBlankCount)
{
    i = 0
    szBlank=""

    while(i < iBlankCount)
    {
        szBlank = cat(szBlank, " ")
        i = i + 1
    }

    return szBlank
}

macro GetLeftBlank(szLine)
{
    i = 0
    iLen = strlen(szLine)

    while (i < iLen)
    {
        if ((szLine[i] != " ") && (szLine[i] != "\t"))
        {
            break;
        }
        i = i + 1
    }

    return i
}

macro GetFunctionList(hbuf, hnewbuf)
{
    isym = 0
    isymMax = GetBufSymCount (hbuf)

    /* 依次取出全部的但前buf符号表中的全部符号 */
    while (isym < isymMax) 
    {
        symbol = GetBufSymLocation(hbuf, isym)
        if (symbol.Type == "Class Placeholder")
        {
            ichild = 0
            hsyml = SymbolChildren(symbol)
            cchild = SymListCount(hsyml)

            while (ichild < cchild)
            {
                childsym = SymListItem(hsyml, ichild)
                AppendBufLine(hnewbuf,childsym.symbol)
                ichild = ichild + 1
            }

            SymListFree(hsyml)
        }

        if (strlen(symbol) > 0)
        {
            if((symbol.Type == "Method") ||
                (symbol.Type == "Function") ||
                (symbol.Type == "Editor Macro"))
            {
                /* 取出类型是函数和宏的符号 */
                symname = symbol.Symbol

                /* 将符号插入到新buf中这样做是为了兼容V2.1 */
                AppendBufLine(hnewbuf,symname)
            }
        }

        isym = isym + 1
    }
}

macro GetFileName(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    if (iLen == 0) return ""

    while (i <= iLen)
    {
        if (sz[iLen-i] == "\\")
        {
            szName = strmid(sz, iLen - i + 1, iLen)
            break
        }
        i = i + 1
    }
    return szName
}

macro GetFunctionDef(hbuf, symbol)
{
    szFunc = ""
    ln = symbol.lnName
    
    if (strlen(symbol) == 0)
    {
        return szFunc
    }

    fIsEnd = 1
    while (ln < symbol.lnLim)
    {
        szLine = GetBufLine(hbuf, ln)

        /* 去掉被注释掉的内容 */
        RetVal = SkipCommentFromString(szLine, fIsEnd)
        szLine = RetVal.szContent
        szLine = TrimString(szLine)
        fIsEnd = RetVal.fIsEnd

        /* 如果是'{'表示函数参数头结束了 */
        ret = strstr(szLine, "{")
        if (ret != 0xffffffff)
        {
            szLine = strmid(szLine, 0, ret)
            szFunc = cat(szFunc, szLine)
            break
        }
        szFunc = cat(szFunc, szLine)
        ln = ln + 1
    }

    return szFunc
}

macro GetReturnValue(szLine)
{
    iLen = strlen(szLine)

	tag = toupper("extern \"C\" ")
	ret = strncmp(toupper(szLine), tag, strlen(tag))
	if (ret != 0xffffffff)
	{
		mid = strmid(szLine, strlen(tag), iLen)
		ret = strrchr(mid, "*")
		if (ret == 0xffffffff)
		{
			tag = toupper("void")
			ret = strncmp(toupper(mid), tag, strlen(tag))
			if (ret != 0xffffffff)
			{
				return "无"
			}
		}
		return mid
	}

	tag = toupper("static ")
	ret = strncmp(toupper(szLine), tag, strlen(tag))
	if (ret != 0xffffffff)
	{
		mid = strmid(szLine, strlen(tag), iLen)
		ret = strrchr(mid, "*")
		if (ret == 0xffffffff)
		{
			tag = toupper("void")
			ret = strncmp(toupper(mid), tag, strlen(tag))
			if (ret != 0xffffffff)
			{
				return "无"
			}
		}
		return mid
	}

	ret = strrchr(szLine, "*")
	if (ret == 0xffffffff)
	{
		tag = toupper("void")
		ret = strncmp(toupper(szLine), tag, strlen(tag))
		if (ret != 0xffffffff)
		{
			return "无"
		}
	}

    return szLine    
}

macro GetWordFromString(hbuf, szLine, nBeg, nEnd, chBeg, chSeparator, chEnd)
{
    if ((nEnd > strlen(szLine) || (nBeg > nEnd))
    {
        return 0
    }

    nMaxLen = 0
    nIdx = nBeg

    /* 先定位到开始字符标记处 */
    while (nIdx < nEnd)
    {
        if (szLine[nIdx] == chBeg)
        {
            break
        }
        nIdx = nIdx + 1
    }

    nBegWord = nIdx + 1

    /* 用于检测chBeg和chEnd的配对情况 */
    iCount = 0

    nEndWord = 0

    /* 以分隔符为标记进行搜索 */
    while (nIdx < nEnd)
    {
        if (szLine[nIdx] == chSeparator)
        {
            szWord = strmid(szLine, nBegWord, nIdx)
            szWord = TrimString(szWord)
            nLen = strlen(szWord)
            if (nMaxLen < nLen)
            {
                nMaxLen = nLen
            }
            AppendBufLine(hbuf, szWord)
            nBegWord = nIdx + 1
        }

        if (szLine[nIdx] == chBeg)
        {
            iCount = iCount + 1
        }

        if (szLine[nIdx] == chEnd)
        {
            iCount = iCount - 1
            nEndWord = nIdx
            if (iCount == 0)
            {
                break
            }
        }
        nIdx = nIdx + 1
    }

    if (nEndWord > nBegWord)
    {
        szWord = strmid(szLine, nBegWord, nEndWord)
        szWord = TrimString(szWord)
        nLen = strlen(szWord)
        if (nMaxLen < nLen)
        {
            nMaxLen = nLen
        }
        AppendBufLine(hbuf, szWord)
    }

    return nMaxLen
}

macro SkipCommentFromString(szLine, isCommentEnd)
{
    nIdx = 0
    RetVal = ""
    fIsEnd = 1
    nLen = strlen(szLine)

    while (nIdx < nLen)
    {
        /* 如果当前行开始还是被注释，或遇到了注释开始的变标记，注释内容改为空格 */
        if ((isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0

            while (nIdx < nLen)
            {
                if (szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    szLine[nIdx+1] = " "
                    szLine[nIdx] = " " 
                    nIdx = nIdx + 1 
                    fIsEnd = 1
                    isCommentEnd = 1
                    break
                }
                szLine[nIdx] = " "
                nIdx = nIdx + 1 
            }

            /* 如果已经到了行尾终止搜索 */
            if(nIdx == nLen)
            {
                break
            }
        }

        /* 如果遇到的是//来注释的说明后面都为注释 */
        if (szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            szLine = strmid(szLine, 0, nIdx)
            break
        }
        nIdx = nIdx + 1
    }

    RetVal.szContent = szLine;
    RetVal.fIsEnd = fIsEnd

    return RetVal
}

macro CommentContent(hbuf, ln, szPreStr, szContent, isEnd)
{
    k = 0
    szLeftBlank = szPreStr
    iLen = strlen(szPreStr)
    while (k < iLen)
    {
        szLeftBlank[k] = " ";
        k = k + 1;
    }

    hNewBuf = newbuf("clip")
    if (hNewBuf == hNil) return

    SetCurrentBuf(hNewBuf)
    PasteBufLine (hNewBuf, 0)
    lnMax = GetBufLineCount(hNewBuf)
    szTmp = TrimString(szContent)

    /* 判断如果剪贴板是0行时对于有些版本会有问题，要排除掉 */
    if (lnMax != 0)
    {
        szLine = GetBufLine(hNewBuf, 0)
        ret = strstr(szLine, szTmp)
        if (ret == 0)
        {
            /* 如果输入窗输入的内容是剪贴板的一部分说明是剪贴过来的取剪贴板中的内容 */
            szContent = TrimString(szLine)
        }
        else
        {
            lnMax = 1
        }
    }
    else
    {
        lnMax = 1
    }
    
    szRet = ""
    nIdx = 0
    while (nIdx < lnMax) 
    {
        if (nIdx != 0)
        {
            szLine = GetBufLine(hNewBuf, nIdx)
            szContent = TrimLeft(szLine)
            szPreStr = szLeftBlank
        }

        iLen = strlen (szContent)
        szTmp = cat(szPreStr,"#");
        if ((iLen == 0) && (nIdx == (lnMax - 1))
        {
            InsBufLine(hbuf, ln, "@szTmp@")
        }
        else
        {
            i = 0
            /* 以每行75个字符处理 */
            while (iLen - i > 75 - k)
            {
                j = 0
                while (j < 75 - k)
                {
                    iNum = szContent[i + j]
                    if (AsciiFromChar(iNum) > 160)
                    {
                        j = j + 2
                    }
                    else
                    {
                        j = j + 1
                    }
                    if ((j > 70 - k) && (szContent[i + j] == " "))
                    {
                        break
                    }
                }
                if ((szContent[i + j] != " "))
                {
                    n = 0;
                    iNum = szContent[i + j + n]

                    /* 如果是中文字符只能成对处理 */
                    while ((iNum != " " ) && (AsciiFromChar (iNum)  < 160))
                    {
                        n = n + 1
                        if ((n >= 3) || (i + j + n >= iLen))
                        {
                            break
                        }
                        iNum = szContent[i + j + n]
                    }
                    if (n < 3)
                    {
                        /* 分段后只有小于3个的字符留在下段则将其以上去 */
                        j = j + n 
                        sz1 = strmid(szContent, i, i + j)
                        sz1 = cat(szPreStr, sz1)
                    }
                    else
                    {
                        /* 大于3个字符的加连字符分段 */
                        sz1 = strmid(szContent, i, i + j)
                        sz1 = cat(szPreStr, sz1)
                        if (sz1[strlen(sz1) - 1] != "-")
                        {
                            sz1 = cat(sz1, "-")                
                        }
                    }
                }
                else
                {
                    sz1 = strmid(szContent, i, i + j)
                    sz1 = cat(szPreStr, sz1)
                }

                InsBufLine(hbuf, ln, "@sz1@")
                ln = ln + 1
                szPreStr = szLeftBlank
                i = i + j
                while (szContent[i] == " ")
                {
                    i = i + 1
                }
            }

            sz1 = strmid(szContent, i, iLen)
            sz1 = cat(szPreStr, sz1)
            if ((isEnd == 1) && (nIdx == (lnMax - 1))
            {
                sz1 = cat(sz1," */")
            }
            InsBufLine(hbuf, ln, "@sz1@")
        }

        ln = ln + 1
        nIdx = nIdx + 1
    }

    closebuf(hNewBuf)

    return ln - 1
}

macro strstr(str1, str2)
{
    i = 0
    j = 0
    len1 = strlen(str1)
    len2 = strlen(str2)

    if ((len1 == 0) || (len2 == 0))
    {
        return 0xffffffff
    }

    while (i < len1)
    {
        if (str1[i] == str2[j])
        {
            while (j < len2)
            {
                j = j + 1
                if (str1[i+j] != str2[j])
                {
                    break
                }
            }
            if (j == len2)
            {
                return i
            }
            j = 0
        }
        i = i + 1
    }

    return 0xffffffff
}

macro strrchr(str, ch)
{
    i = strlen(str)

    while (i != 0)
    {
        if (str[i-1] == ch)
        {
            return i - 1
        }
        i = i - 1
    }

    return 0xffffffff
}

macro strncmp(str1, str2, n)
{
    if ((strlen(str1) == 0) || (strlen(str2) == 0) || (n == 0))
    {
        return 0xffffffff
    }

    i = 0
    while (i < n)
    {
        if (str1[i] == '\0' || str2[i] == '\0' || str1[i] != str2[i])
        {
            return 0xffffffff
        }
        i = i + 1
    }

    return 0
}

macro TrimLeft(szLine)
{
    iLen = strlen(szLine)
    if (iLen == 0)
    {
        return szLine
    }

    i = 0
    while (i < iLen)
    {
        if ((szLine[i] != " ") && (szLine[i] != "\t"))
        {
            break
        }
        i = i + 1
    }

    return strmid(szLine, i, iLen)
}

macro TrimRight(szLine)
{
    iLen = strlen(szLine)
    if (iLen == 0)
    {
        return szLine
    }

    i = iLen
    while (i > 0)
    {
        i = i - 1
        if ((szLine[i] != " ") && (szLine[i] != "\t"))
        {
            break
        }
    }

    return strmid(szLine, 0, i + 1)
}

macro TrimString(szLine)
{
    szLine = TrimLeft(szLine)
    szLine = TrimRight(szLine)
    return szLine
}

macro SetSystemConfig(language)
{
    if (language == 1)
    {
        szLanguage = Ask("Please select language: 0 - Chinese, 1 - English")
        if (szLanguage == "#")
        {
            SetReg("LANGUAGE", 0)
        }
        else
        {
            SetReg("LANGUAGE", szLanguage)
        }

        szName = Ask("Please input your name:")
        if (szName == "#")
        {
            SetReg("MYNAME", "Mr.Zhang")
        }
        else
        {
            SetReg("MYNAME", szName)
        }

        szCompany = Ask("Please input company name:")
        if (szCompany == "#")
        {
            SetReg("COMPANY", "xxx Co.xxx, Ltd.")
        }
        else
        {
            SetReg("COMPANY", szCompany)
        }
    }
    else
    {
        szLanguage = Ask("请选择语言：0 - 中文，1 - 英文")
        if (szLanguage == "#")
        {
            SetReg("LANGUAGE", 0)
        }
        else
        {
            SetReg("LANGUAGE", szLanguage)
        }

        szName = Ask("请输入你的名字：")
        if (szName == "#")
        {
            SetReg("MYNAME", "Mr.Zhang")
        }
        else
        {
            SetReg("MYNAME", szName)
        }

        szCompany = Ask("请输入公司名称：")
        if (szCompany == "#")
        {
            SetReg("COMPANY", "xxx Co.xxx, Ltd.")
        }
        else
        {
            SetReg("COMPANY", szCompany)
        }
    }
}

macro AddPromblemNo()
{
    szQuestion = ""
    language = GetReg(LANGUAGE)

    if (language == 1)
    {
        szQuestion = Ask("Please Input problem number:")
    }
    else
    {
        szQuestion = Ask("请输入问题单号：")
    }

    if (szQuestion == "#")
    {
        SetReg("PNO", "")
    }
    else
    {
        SetReg("PNO", szQuestion)
    }
}

macro RestoreCommand(hbuf, szCmd)
{
    if (szCmd == "ca")
    {
        SetBufSelText(hbuf, "se")
        szCmd = "case"
    }
    else if (szCmd == "el")
    {
        SetBufSelText(hbuf, "se")
        szCmd = "else"
    }

    return szCmd
}

macro InsertReviseAction(szAction)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)

    language = GetReg(LANGUAGE)
    if (language != 1)
    {
        language = 0
    }

    szName = GetReg(MYNAME)
    if (strlen(szName) == 0)
    {
        if (language == 1)
        {
            szName = Ask("Please input your name:")
        }
        else
        {
            szName = Ask("请输入你的名字：")
        }

        if (strlen(szName) > 0)
        {
            SetReg(MYNAME, szName)
        }
        else
        {
            szName = "Mr.Zhang"
        }
    }

    /* 获取系统时间 */
    SysTime = GetSysTime(1)
    year = SysTime.Year
    mon = SysTime.month
    day = SysTime.day

    if ((sel.lnFirst == sel.lnLast) && (sel.ichFirst == sel.ichLim))
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine(hbuf, sel.lnFirst)
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine, 0, nLeft)
    }

    szQuestion = GetReg("PNO")
    if (strlen(szQuestion) > 0)
    {
        if (language == 1)
        {
            InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: @szAction@ by @szName@, @year@/@mon@/@day@   QuestionNum: @szQuestion@ */");
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   @szAction@ by @szName@, @year@/@mon@/@day@   QuestionNum: @szQuestion@ */");            
        }
        else
        {
            InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: @szAction@ by @szName@, @year@/@mon@/@day@   问题单号: @szQuestion@ */");
            InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   @szAction@ by @szName@, @year@/@mon@/@day@   问题单号: @szQuestion@ */");
        }
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: @szAction@ by @szName@, @year@/@mon@/@day@ */");
        InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   @szAction@ by @szName@, @year@/@mon@/@day@ */");
    }

    SetBufIns(hbuf, sel.lnFirst + 1, strlen(szLeft))
}

macro ExpandProcCN(szName, wordinfo, szLine, szLine1, ln, sel)
{
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0) stop

    hbuf = GetWndBuf(hwnd)

    if (szCmd == "file")
    {
        /* 插入文件头 */
        DelBufLine(hbuf, ln)
        InsertFileHeaderCN(hbuf, 0, szName, "")
        return
    }
    else if (szCmd == "func")
    {
        /* 插入函数头 */
        DelBufLine(hbuf, ln)
        lnMax = GetBufLineCount(hbuf)
        if (ln != lnMax)
        {
            szNextLine = GetBufLine(hbuf, ln)
            if ((strstr(szNextLine,"(") != 0xffffffff) || (nVer != 2))
            {
                symbol = GetCurSymbol()
                if (strlen(symbol) != 0)
                {
                    InsertFuncHeaderCN(hbuf, ln, symbol, szName, 0)
                    return
                }
            }
        }
    }
}

macro InsertFileHeaderCN(hbuf, ln, szName, szContent)
{
    hnewbuf = newbuf("")
    if (hnewbuf == hNil) stop
    szCompany = GetReg("COMPANY")

    SysTime = GetSysTime(1)
    szTime = SysTime.Date
    year2 = SysTime.Year
    year1 = year2 - 1

    GetFunctionList(hbuf, hnewbuf)
    InsBufLine(hbuf, ln + 0,  "/******************************************************************************")
    InsBufLine(hbuf, ln + 1,  "")
    InsBufLine(hbuf, ln + 2,  "            版权所有 (C), @year1@-@year2@, @szCompany@")
    InsBufLine(hbuf, ln + 3,  "")
    InsBufLine(hbuf, ln + 4,  " ******************************************************************************")
    szFileName = GetFileName(GetBufName(hbuf))
    InsBufLine(hbuf, ln + 5,  "    文 件 名 : @szFileName@")
    InsBufLine(hbuf, ln + 6,  "    版 本 号 : V1.0")
    InsBufLine(hbuf, ln + 7,  "    作    者 : @szName@")
    InsBufLine(hbuf, ln + 8,  "    生成日期 : @szTime@")
    iLen = strlen(szContent)
    nlnDesc = ln
    InsBufLine(hbuf, ln + 9, "    功能描述 : @szContent@")
    closebuf(hnewbuf)
    InsBufLine(hbuf, ln + 10, "    修改历史 :")
    InsBufLine(hbuf, ln + 11, "******************************************************************************/")

    if (strlen(szContent) == 0)
    {
        szContent = Ask("请输入文件功能描述的内容：")
        DelBufLine(hbuf, nlnDesc + 9)
        CommentContent(hbuf, nlnDesc + 9, "    功能描述 : ", szContent, 0)
    }
}

macro InsertFuncHeaderCN(hbuf, ln, szFunc, szMyName, newFunc)
{
    iIns = 0

    if (newFunc != 1)
    {
        symbol = GetSymbolLocationFromLn(hbuf, ln)
        if (strlen(symbol) > 0)
        {
            hTmpBuf = NewBuf("Tempbuf")
            if(hTmpBuf == hNil) stop

            /* 将文件参数头整理成一行并去掉了注释 */
            szLine = GetFunctionDef(hbuf, symbol)
            iBegin = symbol.ichName

            /* 取出返回值定义 */
            szTemp = strmid(szLine, 0, iBegin)
            szTemp = TrimString(szTemp)
            if (symbol.Type == "Function")
            {
                szRet = GetReturnValue(szTemp)
            }
            else if (symbol.Type == "Member Function")
            {
				index = strrchr(szTemp, " ")
				if (index != 0xffffffff)
				{
					szRet = strmid(szTemp, 0, index)
					ret = strrchr(szRet, "*")
					if (ret == 0xffffffff)
					{
						tag = toupper("void")
						ret = strncmp(toupper(szRet), tag, strlen(tag))
						if (ret != 0xffffffff)
						{
							szRet = "无"
						}
					}
				}
            }
            else
            {
                szRet = ""
            }

            /* 从函数头分离出函数参数 */
            nMaxParamSize = GetWordFromString(hTmpBuf, szLine, iBegin, strlen(szLine), "(", "," , ")")
            lnMax = GetBufLineCount(hTmpBuf)
            ln = symbol.lnFirst
            SetBufIns(hbuf, ln, 0)
        }
    }
    else
    {
        lnMax = 0
        szLine = ""
        szRet = ""
    }

    InsBufLine(hbuf, ln, "/*****************************************************************************")
    if (strlen(szFunc) > 0)
    {
        InsBufLine(hbuf, ln + 1, "    函 数 名 : @szFunc@")
    }
    else
    {
        InsBufLine(hbuf, ln + 1, "    函 数 名 : ###")
    }
    oldln = ln
    InsBufLine(hbuf, ln + 2, "    功能描述 : ")
    szIns = "    输入参数 : "
    if (newFunc != 1)
    {
        /* 对于已经存在的函数插入函数参数 */
        i = 0
        while (i < lnMax) 
        {
            szTmp = GetBufLine(hTmpBuf, i)
            nLen = strlen(szTmp);
            szBlank = CreateBlankString(nMaxParamSize - nLen + 2)
            //szTmp = cat(szTmp, szBlank)
            ln = ln + 1
            szTmp = cat(szIns, szTmp)
            InsBufLine(hbuf, ln + 2, "@szTmp@")
            iIns = 1
            szIns = "               "
            i = i + 1
        }    
        closebuf(hTmpBuf)
    }

    if (iIns == 0)
    {       
        ln = ln + 1
        InsBufLine(hbuf, ln + 2, "    输入参数 : 无")
    }
    InsBufLine(hbuf, ln + 3, "    输出参数 : 无")
    InsBufLine(hbuf, ln + 4, "    返 回 值 : @szRet@")

    if (strlen(szMyName) > 0)
    {
        InsBufLine(hbuf, ln + 5, "    作    者 : @szMyName@")
    }
    else
    {
        InsBufLine(hbuf, ln+5, "    作    者 : ###")
    }

    SysTime = GetSysTime(1);
    szTime = SysTime.Date
    InsBufLine(hbuf, ln + 6, "    日    期 : @szTime@")
    InsBufLine(hbuf, ln + 7, "*****************************************************************************/")
      
    hwnd = GetCurrentWnd()
    if (hwnd == 0) stop
    sel = GetWndSel(hwnd)
    sel.ichFirst = 0
    sel.ichLim = sel.ichFirst
    sel.lnFirst = ln + 14
    sel.lnLast = ln + 14
    szContent = Ask("请输入函数功能描述的内容：")
    setWndSel(hwnd, sel)
    DelBufLine(hbuf, oldln + 2)

    /* 显示输入的功能描述内容 */
    newln = CommentContent(hbuf, oldln + 2, "    功能描述 : ", szContent, 0) - 2
    ln = ln + newln - oldln

    return ln + 11
}

