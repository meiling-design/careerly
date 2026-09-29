import svgPaths from "./svg-2ne9tl3gkk";

function Signal() {
  return (
    <div className="h-[12px] relative shrink-0 w-[16px]" data-name="signal">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 16 12" width="16">
        <g clipPath="url(#clip0_0_10)" id="signal">
          <path d={svgPaths.p1b5f3f80} fill="#374151" id="Vector" />
          <path d={svgPaths.p37739680} fill="#374151" id="Vector_2" />
          <path d={svgPaths.p1d305000} fill="#9CA3AF" id="Vector_3" />
          <path d={svgPaths.p19238df0} fill="#9CA3AF" id="Vector_4" />
        </g>
        <defs>
          <clipPath id="clip0_0_10">
            <rect fill="white" height="12" width="16" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Wifi() {
  return (
    <div className="h-[12px] relative shrink-0 w-[18px]" data-name="wifi">
      <svg className="absolute block inset-0 size-full" fill="none" height="12" preserveAspectRatio="none" viewBox="0 0 18 12" width="18">
        <g clipPath="url(#clip0_0_6)" id="wifi">
          <path d={svgPaths.pa04fc80} id="Vector" stroke="#9CA3AF" />
          <path d={svgPaths.p7154300} fill="#374151" id="Vector_2" />
          <path d={svgPaths.p9a4ab80} fill="#9CA3AF" id="Vector_3" />
        </g>
        <defs>
          <clipPath id="clip0_0_6">
            <rect fill="white" height="12" width="18" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Frame() {
  return (
    <div className="absolute content-stretch flex gap-[6px] items-center left-[326px] top-[22px]" data-name="Frame">
      <Signal />
      <Wifi />
    </div>
  );
}

function StatusBar() {
  return (
    <div className="h-[37px] relative shrink-0 w-full" data-name="StatusBar">
      <p className="[word-break:break-word] absolute font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[19.5px] left-[24px] not-italic text-[#374151] text-[13px] top-[18px] whitespace-nowrap">9:41</p>
      <Frame />
    </div>
  );
}

function Frame1() {
  return <div className="bg-[#e8e4f0] flex-[1_0_0] h-px min-w-px relative" data-name="Frame" />;
}

function Divider() {
  return (
    <div className="absolute content-stretch flex h-px items-start left-0 px-[20px] right-0 top-[203px]" data-name="Divider">
      <Frame1 />
    </div>
  );
}

function BackIcon() {
  return (
    <div className="relative shrink-0 size-[15px]" data-name="BackIcon">
      <svg className="absolute block inset-0 size-full" fill="none" height="15" preserveAspectRatio="none" viewBox="0 0 15 15" width="15">
        <g id="BackIcon">
          <path d={svgPaths.p171bcb00} id="Vector" stroke="#374151" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" />
        </g>
      </svg>
    </div>
  );
}

function BackBtn() {
  return (
    <div className="bg-white content-stretch drop-shadow-[0px_2px_4px_rgba(0,0,0,0.06)] flex items-center justify-center relative rounded-[12px] shrink-0 size-[32px]" data-name="BackBtn">
      <BackIcon />
    </div>
  );
}

function Frame2() {
  return (
    <div className="[word-break:break-word] content-stretch flex flex-[1_0_0] flex-col gap-[2px] items-start min-w-px not-italic relative whitespace-nowrap" data-name="Frame">
      <p className="font-['Inter:Extra_Bold','Noto_Sans_JP:Black','Noto_Sans_SC:Black',sans-serif] font-extrabold leading-[28px] relative shrink-0 text-[#1f2937] text-[22px]">成长记录</p>
      <p className="font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] relative shrink-0 text-[#9ca3af] text-[13px]">每一次变化，都是成长的痕迹。</p>
    </div>
  );
}

function TitleRow() {
  return (
    <div className="content-stretch flex gap-[12px] items-center pb-[6px] relative shrink-0 w-full" data-name="TitleRow">
      <BackBtn />
      <Frame2 />
    </div>
  );
}

function Header() {
  return (
    <div className="content-stretch flex flex-col h-[90px] items-start mb-[-15px] pb-[18px] pt-[16px] px-[24px] relative shrink-0 w-full" data-name="Header">
      <TitleRow />
    </div>
  );
}

function MonthRow() {
  return (
    <div className="content-stretch flex items-start pb-[12px] pl-[4px] relative shrink-0 w-full" data-name="MonthRow">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[16px] not-italic relative shrink-0 text-[#9ca3af] text-[12px] tracking-[0.5px] whitespace-nowrap">2026年9月</p>
    </div>
  );
}

function Frame4() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[20px] shrink-0 size-[40px]" data-name="Frame">
      <div aria-hidden className="absolute border border-[#ededf2] border-solid inset-0 pointer-events-none rounded-[20px]" />
      <p className="[word-break:break-word] font-['Inter:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#374151] text-[14px] whitespace-nowrap">6</p>
    </div>
  );
}

function Frame3() {
  return (
    <div className="content-stretch flex flex-col gap-[8px] items-center relative shrink-0 w-[40px]" data-name="Frame">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#b0b7c3] text-[11px] whitespace-nowrap">日</p>
      <Frame4 />
    </div>
  );
}

function Frame6() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[20px] shrink-0 size-[40px]" data-name="Frame">
      <div aria-hidden className="absolute border border-[#ededf2] border-solid inset-0 pointer-events-none rounded-[20px]" />
      <p className="[word-break:break-word] font-['Inter:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#374151] text-[14px] whitespace-nowrap">7</p>
    </div>
  );
}

function Frame5() {
  return (
    <div className="content-stretch flex flex-col gap-[8px] items-center relative shrink-0 w-[40px]" data-name="Frame">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#b0b7c3] text-[11px] whitespace-nowrap">一</p>
      <Frame6 />
    </div>
  );
}

function Frame8() {
  return (
    <div className="content-stretch drop-shadow-[0px_4px_6px_rgba(123,126,218,0.25)] flex items-center justify-center relative rounded-[20px] shrink-0 size-[40px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(108, 126, 225) 0%, rgb(160, 127, 232) 100%)" }} data-name="Frame">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[normal] not-italic relative shrink-0 text-[14px] text-white whitespace-nowrap">8</p>
    </div>
  );
}

function Frame7() {
  return (
    <div className="content-stretch flex flex-col gap-[8px] items-center relative shrink-0 w-[40px]" data-name="Frame">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold',sans-serif] font-bold leading-[normal] not-italic relative shrink-0 text-[#5b6ad0] text-[11px] whitespace-nowrap">二</p>
      <Frame8 />
    </div>
  );
}

function Frame10() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[20px] shrink-0 size-[40px]" data-name="Frame">
      <div aria-hidden className="absolute border border-[#ededf2] border-solid inset-0 pointer-events-none rounded-[20px]" />
      <p className="[word-break:break-word] font-['Inter:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#374151] text-[14px] whitespace-nowrap">9</p>
    </div>
  );
}

function Frame9() {
  return (
    <div className="content-stretch flex flex-col gap-[8px] items-center relative shrink-0 w-[40px]" data-name="Frame">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#b0b7c3] text-[11px] whitespace-nowrap">三</p>
      <Frame10 />
    </div>
  );
}

function Frame12() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[20px] shrink-0 size-[40px]" data-name="Frame">
      <div aria-hidden className="absolute border border-[#ededf2] border-solid inset-0 pointer-events-none rounded-[20px]" />
      <p className="[word-break:break-word] font-['Inter:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#374151] text-[14px] whitespace-nowrap">10</p>
    </div>
  );
}

function Frame11() {
  return (
    <div className="content-stretch flex flex-col gap-[8px] items-center relative shrink-0 w-[40px]" data-name="Frame">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#b0b7c3] text-[11px] whitespace-nowrap">四</p>
      <Frame12 />
    </div>
  );
}

function Frame14() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[20px] shrink-0 size-[40px]" data-name="Frame">
      <div aria-hidden className="absolute border border-[#ededf2] border-solid inset-0 pointer-events-none rounded-[20px]" />
      <p className="[word-break:break-word] font-['Inter:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#374151] text-[14px] whitespace-nowrap">11</p>
    </div>
  );
}

function Frame13() {
  return (
    <div className="content-stretch flex flex-col gap-[8px] items-center relative shrink-0 w-[40px]" data-name="Frame">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#b0b7c3] text-[11px] whitespace-nowrap">五</p>
      <Frame14 />
    </div>
  );
}

function Frame16() {
  return (
    <div className="bg-white content-stretch flex items-center justify-center relative rounded-[20px] shrink-0 size-[40px]" data-name="Frame">
      <div aria-hidden className="absolute border border-[#ededf2] border-solid inset-0 pointer-events-none rounded-[20px]" />
      <p className="[word-break:break-word] font-['Inter:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#374151] text-[14px] whitespace-nowrap">12</p>
    </div>
  );
}

function Frame15() {
  return (
    <div className="content-stretch flex flex-col gap-[8px] items-center relative shrink-0 w-[40px]" data-name="Frame">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[normal] not-italic relative shrink-0 text-[#b0b7c3] text-[11px] whitespace-nowrap">六</p>
      <Frame16 />
    </div>
  );
}

function WeekDays() {
  return (
    <div className="content-stretch flex items-start justify-between pb-[8px] px-[4px] relative shrink-0 w-full" data-name="WeekDays">
      <Frame3 />
      <Frame5 />
      <Frame7 />
      <Frame9 />
      <Frame11 />
      <Frame13 />
      <Frame15 />
    </div>
  );
}

function CalendarSection() {
  return (
    <div className="content-stretch flex flex-col items-start mb-[-15px] pb-[16px] px-[20px] relative shrink-0 w-full" data-name="CalendarSection">
      <MonthRow />
      <WeekDays />
    </div>
  );
}

function DateLabel() {
  return (
    <div className="content-stretch flex flex-col items-end pt-[16px] relative shrink-0 w-[56px]" data-name="DateLabel">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[16px] not-italic relative shrink-0 text-[#a0a7b8] text-[11px] tracking-[-0.2px] whitespace-nowrap">08/2026</p>
    </div>
  );
}

function Dot() {
  return <div className="bg-[#6c7ee1] relative rounded-[5px] shadow-[0px_0px_0px_0px_rgba(108,126,225,0.19)] shrink-0 size-[10px]" data-name="Dot" />;
}

function DotWrapper() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[18px] relative shrink-0" data-name="DotWrapper">
      <Dot />
    </div>
  );
}

function Line() {
  return <div className="h-[148px] relative shrink-0 w-[1.5px]" style={{ backgroundImage: "linear-gradient(90.58068058589271deg, rgb(197, 200, 224) 25%, rgba(197, 200, 224, 0) 75%)" }} data-name="Line" />;
}

function LineWrapper() {
  return (
    <div className="content-stretch flex flex-[1_0_0] flex-col items-start min-h-px pt-[5px] relative" data-name="LineWrapper">
      <Line />
    </div>
  );
}

function TimelineCol() {
  return (
    <div className="content-stretch flex flex-col h-[180px] items-center px-[14px] relative shrink-0 w-[44px]" data-name="TimelineCol">
      <DotWrapper />
      <LineWrapper />
    </div>
  );
}

function Tag() {
  return (
    <div className="absolute bg-[#6c7ee1] left-[-0.5px] rounded-[99px] size-[42px] top-[0.5px]" data-name="Tag">
      <p className="[word-break:break-word] absolute font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[14px] left-[calc(50%-10.5px)] not-italic text-[10px] text-white top-[calc(50%-6.5px)] whitespace-nowrap">项目</p>
    </div>
  );
}

function TitleArea() {
  return (
    <div className="absolute h-[21px] left-[49.5px] top-[4.5px] w-[169px]" data-name="TitleArea">
      <p className="[word-break:break-word] absolute font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] left-0 not-italic text-[#1f2937] text-[15px] top-0 whitespace-nowrap">新增 AI Agent 项目</p>
    </div>
  );
}

function CardHeader() {
  return (
    <div className="h-[42px] relative shrink-0 w-full" data-name="CardHeader">
      <Tag />
      <TitleArea />
      <p className="[word-break:break-word] absolute font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[16px] left-[52.5px] not-italic text-[#a0a7b8] text-[11px] top-[25.5px] tracking-[-0.2px] whitespace-nowrap">08/2026</p>
    </div>
  );
}

function Card() {
  return (
    <div className="bg-[#eef1fe] content-stretch flex flex-col gap-[10px] items-start p-[16px] relative rounded-bl-[20px] rounded-br-[20px] rounded-tl-[4px] rounded-tr-[20px] shrink-0 w-full" data-name="Card">
      <CardHeader />
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#6b7280] text-[13px] w-full">完成 AI 招聘助手 MVP 上线，主导产品规划与落地。</p>
    </div>
  );
}

function CardWrapper() {
  return (
    <div className="content-stretch flex flex-[1_0_0] flex-col items-start min-w-px pb-[20px] pt-[8px] relative" data-name="CardWrapper">
      <Card />
    </div>
  );
}

function EventRow() {
  return (
    <div className="content-stretch flex h-[150px] items-start relative shrink-0 w-full" data-name="EventRow1">
      <DateLabel />
      <TimelineCol />
      <CardWrapper />
    </div>
  );
}

function DateLabel1() {
  return (
    <div className="content-stretch flex flex-col items-end pt-[16px] relative shrink-0 w-[56px]" data-name="DateLabel">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[16px] not-italic relative shrink-0 text-[#a0a7b8] text-[11px] tracking-[-0.2px] whitespace-nowrap">06/2026</p>
    </div>
  );
}

function Dot1() {
  return <div className="bg-[#ff9c6e] relative rounded-[5px] shadow-[0px_0px_0px_0px_rgba(255,156,110,0.19)] shrink-0 size-[10px]" data-name="Dot" />;
}

function DotWrapper1() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[18px] relative shrink-0" data-name="DotWrapper">
      <Dot1 />
    </div>
  );
}

function Line1() {
  return <div className="h-[148px] relative shrink-0 w-[1.5px]" style={{ backgroundImage: "linear-gradient(90.58068058589271deg, rgb(217, 191, 176) 25%, rgba(217, 191, 176, 0) 75%)" }} data-name="Line" />;
}

function LineWrapper1() {
  return (
    <div className="content-stretch flex flex-[1_0_0] flex-col items-start min-h-px pt-[5px] relative" data-name="LineWrapper">
      <Line1 />
    </div>
  );
}

function TimelineCol1() {
  return (
    <div className="content-stretch flex flex-col h-[180px] items-center px-[14px] relative shrink-0 w-[44px]" data-name="TimelineCol">
      <DotWrapper1 />
      <LineWrapper1 />
    </div>
  );
}

function TitleArea1() {
  return (
    <div className="absolute content-stretch flex flex-col h-[21px] items-start left-[53px] top-[3px] w-[124px]" data-name="TitleArea">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[#1f2937] text-[15px] whitespace-nowrap">完成用户研究认证</p>
    </div>
  );
}

function Tag1() {
  return (
    <div className="absolute bg-[#ff9c6e] content-stretch flex flex-col items-center justify-center left-0 px-[11px] py-[14px] rounded-[20px] top-0 w-[42px]" data-name="Tag">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[14px] not-italic relative shrink-0 text-[10px] text-white w-full">能力</p>
    </div>
  );
}

function CardHeader1() {
  return (
    <div className="h-[42px] relative shrink-0 w-full" data-name="CardHeader">
      <TitleArea1 />
      <Tag1 />
      <p className="[word-break:break-word] absolute font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[16px] left-[53px] not-italic text-[#a0a7b8] text-[11px] top-[25px] tracking-[-0.2px] whitespace-nowrap">06/2026</p>
    </div>
  );
}

function Card1() {
  return (
    <div className="bg-[#fff2ec] content-stretch flex flex-col gap-[10px] items-start p-[16px] relative rounded-bl-[20px] rounded-br-[20px] rounded-tl-[4px] rounded-tr-[20px] shrink-0 w-full" data-name="Card">
      <CardHeader1 />
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#6b7280] text-[13px] w-full">通过专项培训，系统强化用户访谈与数据分析能力。</p>
    </div>
  );
}

function CardWrapper1() {
  return (
    <div className="content-stretch flex flex-[1_0_0] flex-col items-start min-w-px pb-[20px] pt-[8px] relative" data-name="CardWrapper">
      <Card1 />
    </div>
  );
}

function EventRow1() {
  return (
    <div className="content-stretch flex h-[150px] items-start relative shrink-0 w-full" data-name="EventRow2">
      <DateLabel1 />
      <TimelineCol1 />
      <CardWrapper1 />
    </div>
  );
}

function DateLabel2() {
  return (
    <div className="content-stretch flex flex-col items-end pt-[16px] relative shrink-0 w-[56px]" data-name="DateLabel">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[16px] not-italic relative shrink-0 text-[#a0a7b8] text-[11px] tracking-[-0.2px] whitespace-nowrap">05/2026</p>
    </div>
  );
}

function Dot2() {
  return <div className="bg-[#b08ae0] relative rounded-[5px] shadow-[0px_0px_0px_0px_rgba(176,138,224,0.19)] shrink-0 size-[10px]" data-name="Dot" />;
}

function DotWrapper2() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[18px] relative shrink-0" data-name="DotWrapper">
      <Dot2 />
    </div>
  );
}

function Line2() {
  return <div className="h-[128px] relative shrink-0 w-[1.5px]" style={{ backgroundImage: "linear-gradient(90.67140418284998deg, rgb(204, 192, 224) 25%, rgba(204, 192, 224, 0) 75%)" }} data-name="Line" />;
}

function LineWrapper2() {
  return (
    <div className="content-stretch flex flex-[1_0_0] flex-col items-start min-h-px pt-[5px] relative" data-name="LineWrapper">
      <Line2 />
    </div>
  );
}

function TimelineCol2() {
  return (
    <div className="content-stretch flex flex-col h-[162px] items-center px-[14px] relative shrink-0 w-[44px]" data-name="TimelineCol">
      <DotWrapper2 />
      <LineWrapper2 />
    </div>
  );
}

function Tag2() {
  return (
    <div className="absolute bg-[#b08ae0] content-stretch flex flex-col items-center justify-center left-0 px-[11px] py-[14px] rounded-[20px] top-0 w-[42px]" data-name="Tag">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[14px] not-italic relative shrink-0 text-[10px] text-white w-full">简历</p>
    </div>
  );
}

function TitleArea2() {
  return (
    <div className="absolute content-stretch flex flex-col h-[21px] items-start left-[52px] top-[3px] w-[114px]" data-name="TitleArea">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[#1f2937] text-[15px] whitespace-nowrap">更新简历 V2</p>
    </div>
  );
}

function CardHeader2() {
  return (
    <div className="h-[42px] relative shrink-0 w-full" data-name="CardHeader">
      <Tag2 />
      <TitleArea2 />
      <p className="[word-break:break-word] absolute font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[16px] left-[52px] not-italic text-[#a0a7b8] text-[11px] top-[25px] tracking-[-0.2px] whitespace-nowrap">05/2026</p>
    </div>
  );
}

function Card2() {
  return (
    <div className="bg-[#f3effe] content-stretch flex flex-col gap-[10px] items-start p-[16px] relative rounded-bl-[20px] rounded-br-[20px] rounded-tl-[4px] rounded-tr-[20px] shrink-0 w-full" data-name="Card">
      <CardHeader2 />
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#6b7280] text-[13px] w-full">补充用户研究案例，完善职业经历描述与项目成果。</p>
    </div>
  );
}

function CardWrapper2() {
  return (
    <div className="content-stretch flex flex-[1_0_0] flex-col items-start min-w-px pb-[20px] pt-[8px] relative" data-name="CardWrapper">
      <Card2 />
    </div>
  );
}

function EventRow2() {
  return (
    <div className="content-stretch flex h-[150px] items-start relative shrink-0 w-full" data-name="EventRow3">
      <DateLabel2 />
      <TimelineCol2 />
      <CardWrapper2 />
    </div>
  );
}

function DateLabel3() {
  return (
    <div className="content-stretch flex flex-col items-end pt-[16px] relative shrink-0 w-[56px]" data-name="DateLabel">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[16px] not-italic relative shrink-0 text-[#a0a7b8] text-[11px] tracking-[-0.2px] whitespace-nowrap">03/2026</p>
    </div>
  );
}

function Dot3() {
  return <div className="bg-[#4cc87a] relative rounded-[5px] shadow-[0px_0px_0px_0px_rgba(76,200,122,0.19)] shrink-0 size-[10px]" data-name="Dot" />;
}

function DotWrapper3() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[18px] relative shrink-0" data-name="DotWrapper">
      <Dot3 />
    </div>
  );
}

function Line3() {
  return <div className="h-[128px] relative shrink-0 w-[1.5px]" style={{ backgroundImage: "linear-gradient(90.67140418284998deg, rgb(176, 217, 192) 25%, rgba(176, 217, 192, 0) 75%)" }} data-name="Line" />;
}

function LineWrapper3() {
  return (
    <div className="content-stretch flex flex-[1_0_0] flex-col items-start min-h-px pt-[5px] relative" data-name="LineWrapper">
      <Line3 />
    </div>
  );
}

function TimelineCol3() {
  return (
    <div className="content-stretch flex flex-col h-[162px] items-center px-[14px] relative shrink-0 w-[44px]" data-name="TimelineCol">
      <DotWrapper3 />
      <LineWrapper3 />
    </div>
  );
}

function Tag3() {
  return (
    <div className="absolute bg-[#4cc87a] content-stretch flex flex-col items-center justify-center left-0 px-[11px] py-[14px] rounded-[20px] top-0 w-[42px]" data-name="Tag">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[14px] not-italic relative shrink-0 text-[10px] text-white w-full">分析</p>
    </div>
  );
}

function TitleArea3() {
  return (
    <div className="absolute content-stretch flex flex-col h-[21px] items-start left-[52px] top-[3px] w-[114px]" data-name="TitleArea">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[#1f2937] text-[15px] whitespace-nowrap">完成职业分析 #2</p>
    </div>
  );
}

function CardHeader3() {
  return (
    <div className="h-[42px] relative shrink-0 w-full" data-name="CardHeader">
      <Tag3 />
      <p className="[word-break:break-word] absolute font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[16px] left-[52px] not-italic text-[#a0a7b8] text-[11px] top-[24px] tracking-[-0.2px] whitespace-nowrap">03/2026</p>
      <TitleArea3 />
    </div>
  );
}

function Card3() {
  return (
    <div className="bg-[rgba(202,219,143,0.35)] content-stretch flex flex-col gap-[10px] items-start p-[16px] relative rounded-bl-[20px] rounded-br-[20px] rounded-tl-[4px] rounded-tr-[20px] shrink-0 w-full" data-name="Card">
      <CardHeader3 />
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_KR:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#6b7280] text-[13px] w-full">与 3 个目标岗位对比分析，最高匹配度 78%。</p>
    </div>
  );
}

function CardWrapper3() {
  return (
    <div className="content-stretch flex flex-[1_0_0] flex-col items-start min-w-px pb-[20px] pt-[8px] relative" data-name="CardWrapper">
      <Card3 />
    </div>
  );
}

function EventRow3() {
  return (
    <div className="content-stretch flex h-[150px] items-start relative shrink-0 w-full" data-name="EventRow4">
      <DateLabel3 />
      <TimelineCol3 />
      <CardWrapper3 />
    </div>
  );
}

function DateLabel4() {
  return (
    <div className="content-stretch flex flex-col items-end pt-[16px] relative shrink-0 w-[56px]" data-name="DateLabel">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[16px] not-italic relative shrink-0 text-[#a0a7b8] text-[11px] tracking-[-0.2px] whitespace-nowrap">01/2026</p>
    </div>
  );
}

function Dot4() {
  return <div className="bg-[#b08ae0] relative rounded-[5px] shadow-[0px_0px_0px_0px_rgba(176,138,224,0.19)] shrink-0 size-[10px]" data-name="Dot" />;
}

function DotWrapper4() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[18px] relative shrink-0" data-name="DotWrapper">
      <Dot4 />
    </div>
  );
}

function TimelineCol4() {
  return (
    <div className="content-stretch flex flex-col h-[154px] items-center px-[14px] relative shrink-0 w-[44px]" data-name="TimelineCol">
      <DotWrapper4 />
    </div>
  );
}

function Tag4() {
  return (
    <div className="absolute bg-[#b08ae0] content-stretch flex flex-col items-center justify-center left-0 px-[11px] py-[14px] rounded-[20px] top-0 w-[42px]" data-name="Tag">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[14px] not-italic relative shrink-0 text-[10px] text-white w-full">简历</p>
    </div>
  );
}

function TitleArea4() {
  return (
    <div className="absolute content-stretch flex flex-col h-[21px] items-start left-[51px] top-[4px] w-[168px]" data-name="TitleArea">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[#1f2937] text-[15px] whitespace-nowrap">创建第一份简历</p>
    </div>
  );
}

function CardHeader4() {
  return (
    <div className="h-[42px] relative shrink-0 w-full" data-name="CardHeader">
      <Tag4 />
      <TitleArea4 />
      <p className="[word-break:break-word] absolute font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[16px] left-[51px] not-italic text-[#a0a7b8] text-[11px] top-[23px] tracking-[-0.2px] whitespace-nowrap">01/2026</p>
    </div>
  );
}

function Card4() {
  return (
    <div className="bg-[#f3effe] content-stretch flex flex-col gap-[10px] items-start p-[16px] relative rounded-bl-[20px] rounded-br-[20px] rounded-tl-[4px] rounded-tr-[20px] shrink-0 w-full" data-name="Card">
      <CardHeader4 />
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[20px] not-italic relative shrink-0 text-[#6b7280] text-[13px] w-full">基于职业经历整理并创建 Resume V1，启动职业成长档案。</p>
    </div>
  );
}

function CardWrapper4() {
  return (
    <div className="content-stretch flex flex-[1_0_0] flex-col items-start min-w-px pb-[12px] pt-[8px] relative" data-name="CardWrapper">
      <Card4 />
    </div>
  );
}

function EventRow4() {
  return (
    <div className="content-stretch flex h-[150px] items-start relative shrink-0 w-full" data-name="EventRow5">
      <DateLabel4 />
      <TimelineCol4 />
      <CardWrapper4 />
    </div>
  );
}

function TimelineArea() {
  return (
    <div className="content-stretch flex flex-col h-[819px] items-start pb-[32px] pt-[12px] px-[20px] relative shrink-0 w-full" data-name="TimelineArea">
      <EventRow />
      <EventRow1 />
      <EventRow2 />
      <EventRow3 />
      <EventRow4 />
    </div>
  );
}

function Frame17() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 top-0 w-[390px]">
      <Header />
      <CalendarSection />
      <TimelineArea />
    </div>
  );
}

function ScrollContent() {
  return (
    <div className="absolute h-[1103px] left-0 top-0 w-[390px]" style={{ backgroundImage: "linear-gradient(142.2023666707054deg, rgb(225, 225, 250) 22.732%, rgb(235, 233, 251) 27.134%, rgb(247, 243, 252) 32.88%, rgb(255, 255, 255) 39.668%)" }} data-name="ScrollContent">
      <Divider />
      <Frame17 />
    </div>
  );
}

function ContentArea() {
  return (
    <div className="h-[986px] overflow-clip relative shrink-0 w-full" data-name="ContentArea">
      <ScrollContent />
    </div>
  );
}

function Container() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[5px] top-[16px] w-[390px]" style={{ backgroundImage: "linear-gradient(142.83921726816368deg, rgb(225, 225, 250) 18.943%, rgb(245, 240, 250) 46.894%, rgb(240, 244, 253) 81.057%)" }} data-name="Container">
      <StatusBar />
      <ContentArea />
    </div>
  );
}

function App() {
  return (
    <div className="absolute bg-[#f2eee9] h-[1044px] left-0 top-0 w-[401px]" data-name="App">
      <Container />
    </div>
  );
}

export default function CareerlyAppInterfaceDesignCopy() {
  return (
    <div className="bg-white relative size-full" data-name="Careerly App Interface Design (Copy)">
      <App />
    </div>
  );
}