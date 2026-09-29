import svgPaths from "./svg-rizcafn0fb";

function Text() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[19.5px] not-italic relative shrink-0 text-[#6b7280] text-[13px] whitespace-nowrap">9:41</p>
    </div>
  );
}

function Icon() {
  return (
    <div className="h-[11.995px] relative shrink-0 w-[15.981px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.9955" preserveAspectRatio="none" viewBox="0 0 15.981 11.9955" width="15.981">
        <g clipPath="url(#clip0_0_289)" id="Icon">
          <path d={svgPaths.p124cd700} fill="#6B7280" id="Vector" />
          <path d={svgPaths.p2ba17c80} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p37914e00} fill="#111827" id="Vector_3" />
          <path d={svgPaths.p2b2fa00} fill="#111827" id="Vector_4" />
        </g>
        <defs>
          <clipPath id="clip0_0_289">
            <rect fill="white" height="11.9955" width="15.981" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Icon1() {
  return (
    <div className="h-[11.995px] relative shrink-0 w-[17.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.9955" preserveAspectRatio="none" viewBox="0 0 17.9835 11.9955" width="17.9835">
        <g clipPath="url(#clip0_0_277)" id="Icon">
          <path d={svgPaths.p2fc15900} id="Vector" stroke="#6B7280" strokeWidth="0.999083" />
          <path d={svgPaths.p35d00d80} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p17068400} fill="#111827" id="Vector_3" />
        </g>
        <defs>
          <clipPath id="clip0_0_277">
            <rect fill="white" height="11.9955" width="17.9835" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container2() {
  return (
    <div className="content-stretch flex gap-[8px] items-center relative shrink-0" data-name="Container">
      <Icon />
      <Icon1 />
    </div>
  );
}

function Container1() {
  return (
    <div className="content-stretch flex items-center justify-between pb-[2px] pt-[12px] px-[24px] relative shrink-0 w-full" data-name="Container">
      <Text />
      <Container2 />
    </div>
  );
}

function Icon2() {
  return (
    <div className="relative shrink-0 size-[17.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="17.9835" preserveAspectRatio="none" viewBox="0 0 17.9835 17.9835" width="17.9835">
        <g id="Icon">
          <path d={svgPaths.p1adbe300} id="Vector" stroke="#4F7EF5" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.87328" />
        </g>
      </svg>
    </div>
  );
}

function Text1() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[21px] not-italic relative shrink-0 text-[#4f7ef5] text-[14px] text-center whitespace-nowrap">返回</p>
    </div>
  );
}

function Button() {
  return (
    <div className="content-stretch flex gap-[6px] items-center relative shrink-0" data-name="Button">
      <Icon2 />
      <Text1 />
    </div>
  );
}

function Text2() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[165px] top-[11px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[22.5px] not-italic relative shrink-0 text-[#111827] text-[15px] whitespace-nowrap">我的简历</p>
    </div>
  );
}

function TopBar() {
  return (
    <div className="absolute content-stretch flex h-[45px] items-center justify-between left-0 px-[20px] py-[12px] right-0 top-0" data-name="TopBar">
      <Button />
      <Text2 />
    </div>
  );
}

function Container7() {
  return <div className="absolute bg-[rgba(255,255,255,0.07)] left-[246.01px] rounded-[41750500px] size-[144px] top-[-40.24px]" data-name="Container" />;
}

function Container8() {
  return <div className="absolute bg-[rgba(255,255,255,0.05)] left-[-32px] rounded-[41750500px] size-[112px] top-[189.23px]" data-name="Container" />;
}

function Container12() {
  return <div className="bg-white relative rounded-[41750500px] shrink-0 size-[6px]" data-name="Container" />;
}

function Text3() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[16.5px] not-italic relative shrink-0 text-[11px] text-white whitespace-nowrap">当前简历</p>
    </div>
  );
}

function Container11() {
  return (
    <div className="absolute bg-[rgba(255,255,255,0.2)] content-stretch flex gap-[6px] items-center left-[-0.04px] px-[12px] py-[4px] rounded-[41750500px] top-[2.18px]" data-name="Container">
      <Container12 />
      <Text3 />
    </div>
  );
}

function Container10() {
  return (
    <div className="h-[42.367px] relative shrink-0 w-full" data-name="Container">
      <Container11 />
    </div>
  );
}

function Heading() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Heading 2">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[28px] not-italic relative shrink-0 text-[22px] text-white whitespace-nowrap">Resume V3</p>
    </div>
  );
}

function Paragraph() {
  return (
    <div className="content-stretch flex flex-col h-[22px] items-start pt-[4px] relative shrink-0 w-[122px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[12px] text-[rgba(255,255,255,0.6)] whitespace-nowrap">更新于 2026.08.27</p>
    </div>
  );
}

function Paragraph1() {
  return (
    <div className="content-stretch flex flex-col h-[20px] items-start pt-[2px] relative shrink-0 w-[122px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[12px] text-[rgba(255,255,255,0.75)] whitespace-nowrap">新增 AI Agent 项目</p>
    </div>
  );
}

function Container14() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[122px]" data-name="Container">
      <Heading />
      <Paragraph />
      <Paragraph1 />
    </div>
  );
}

function Icon3() {
  return (
    <div className="relative shrink-0 size-[21.988px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.9884" preserveAspectRatio="none" viewBox="0 0 21.9884 21.9884" width="21.9884">
        <g id="Icon">
          <path d={svgPaths.p1ac19cc0} id="Vector" stroke="white" strokeWidth="1.55751" />
          <path d={svgPaths.p37a79600} id="Vector_2" stroke="white" strokeLinecap="round" strokeWidth="1.55751" />
        </g>
      </svg>
    </div>
  );
}

function Container15() {
  return (
    <div className="bg-[rgba(255,255,255,0.18)] content-stretch flex items-center justify-center relative rounded-[14px] shrink-0 size-[48px]" data-name="Container">
      <Icon3 />
    </div>
  );
}

function Container13() {
  return (
    <div className="content-stretch flex items-start justify-between relative shrink-0 w-full" data-name="Container">
      <Container14 />
      <Container15 />
    </div>
  );
}

function Paragraph2() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[25.5px] not-italic relative shrink-0 text-[17px] text-center text-white whitespace-nowrap">4</p>
    </div>
  );
}

function Paragraph3() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-center pt-[2px] relative shrink-0 w-[95.333px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[10px] text-[rgba(255,255,255,0.65)] text-center whitespace-nowrap">段经历</p>
    </div>
  );
}

function Container17() {
  return (
    <div className="bg-[rgba(255,255,255,0.14)] content-stretch flex flex-[95_0_0] flex-col items-start min-w-px py-[10px] relative rounded-[16px]" data-name="Container">
      <Paragraph2 />
      <Paragraph3 />
    </div>
  );
}

function Paragraph4() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[25.5px] not-italic relative shrink-0 text-[17px] text-center text-white whitespace-nowrap">6</p>
    </div>
  );
}

function Paragraph5() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-center pt-[2px] relative shrink-0 w-[95.333px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[10px] text-[rgba(255,255,255,0.65)] text-center whitespace-nowrap">个项目</p>
    </div>
  );
}

function Container18() {
  return (
    <div className="bg-[rgba(255,255,255,0.14)] content-stretch flex flex-[95_0_0] flex-col items-start min-w-px py-[10px] relative rounded-[16px]" data-name="Container">
      <Paragraph4 />
      <Paragraph5 />
    </div>
  );
}

function Paragraph6() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[25.5px] not-italic relative shrink-0 text-[17px] text-center text-white whitespace-nowrap">12</p>
    </div>
  );
}

function Paragraph7() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-center pt-[2px] relative shrink-0 w-[95.333px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[10px] text-[rgba(255,255,255,0.65)] text-center whitespace-nowrap">项技能</p>
    </div>
  );
}

function Container19() {
  return (
    <div className="bg-[rgba(255,255,255,0.14)] content-stretch flex flex-[95_0_0] flex-col items-start min-w-px py-[10px] relative rounded-[16px]" data-name="Container">
      <Paragraph6 />
      <Paragraph7 />
    </div>
  );
}

function Container16() {
  return (
    <div className="content-stretch flex gap-[12px] h-[79px] items-start pt-[16px] relative shrink-0 w-full" data-name="Container">
      <Container17 />
      <Container18 />
      <Container19 />
    </div>
  );
}

function Text4() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[18px] not-italic relative shrink-0 text-[12px] text-[rgba(255,255,255,0.6)] whitespace-nowrap">最高匹配</p>
    </div>
  );
}

function Text5() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[22.5px] not-italic relative shrink-0 text-[15px] text-white whitespace-nowrap">86%</p>
    </div>
  );
}

function Container21() {
  return (
    <div className="content-stretch flex gap-[8px] items-center relative shrink-0" data-name="Container">
      <Text4 />
      <Text5 />
    </div>
  );
}

function Icon4() {
  return (
    <div className="relative shrink-0 size-[11.995px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.9955" preserveAspectRatio="none" viewBox="0 0 11.9955 11.9955" width="11.9955">
        <g id="Icon">
          <path d={svgPaths.p23b85e00} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.09959" />
        </g>
      </svg>
    </div>
  );
}

function Button1() {
  return (
    <div className="bg-[rgba(255,255,255,0.22)] content-stretch flex gap-[6px] items-center relative rounded-[41750500px] shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[18px] not-italic relative shrink-0 text-[12px] text-center text-white whitespace-nowrap">查看详情</p>
      <Icon4 />
    </div>
  );
}

function Container20() {
  return (
    <div className="content-stretch flex h-[39px] items-center justify-between pt-[16px] relative shrink-0 w-[310px]" data-name="Container">
      <Container21 />
      <Button1 />
    </div>
  );
}

function Container9() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 p-[20px] top-0 w-[350px]" data-name="Container">
      <Container10 />
      <Container13 />
      <Container16 />
      <Container20 />
    </div>
  );
}

function Container6() {
  return (
    <div className="h-[269px] overflow-clip relative rounded-[24px] shrink-0 w-full" style={{ backgroundImage: "linear-gradient(142.45514931491584deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container">
      <Container7 />
      <Container8 />
      <Container9 />
    </div>
  );
}

function Paragraph8() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] tracking-[0.275px] uppercase whitespace-nowrap">历史版本 · 左滑操作</p>
    </div>
  );
}

function Icon5() {
  return (
    <div className="relative shrink-0 size-[17.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="17.9835" preserveAspectRatio="none" viewBox="0 0 17.9835 17.9835" width="17.9835">
        <g id="Icon">
          <path d={svgPaths.p269e2a00} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.64849" />
        </g>
      </svg>
    </div>
  );
}

function Button2() {
  return (
    <div className="content-stretch flex flex-[80_0_0] flex-col gap-[4px] h-full items-center justify-center min-w-px relative" style={{ backgroundImage: "linear-gradient(136.46880071438582deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Button">
      <Icon5 />
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[14px] not-italic relative shrink-0 text-[10px] text-center text-white whitespace-nowrap">设为当前</p>
    </div>
  );
}

function Icon6() {
  return (
    <div className="relative shrink-0 size-[17.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="17.9835" preserveAspectRatio="none" viewBox="0 0 17.9835 17.9835" width="17.9835">
        <g id="Icon">
          <path d={svgPaths.p30673340} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.49863" />
        </g>
      </svg>
    </div>
  );
}

function Button3() {
  return (
    <div className="bg-[#ff3b30] content-stretch flex flex-[80_0_0] flex-col gap-[4px] h-full items-center justify-center min-w-px relative" data-name="Button">
      <Icon6 />
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[14px] not-italic relative shrink-0 text-[10px] text-center text-white whitespace-nowrap">删除</p>
    </div>
  );
}

function Container24() {
  return (
    <div className="absolute content-stretch flex h-[76px] items-start left-[190.02px] top-0 w-[160px]" data-name="Container">
      <Button2 />
      <Button3 />
    </div>
  );
}

function Icon7() {
  return (
    <div className="relative shrink-0 size-[17.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="17.9835" preserveAspectRatio="none" viewBox="0 0 17.9835 17.9835" width="17.9835">
        <g clipPath="url(#clip0_0_286)" id="Icon">
          <path d={svgPaths.p1f922870} id="Vector" stroke="#4F7EF5" strokeWidth="1.34876" />
          <path d={svgPaths.pb2c3840} id="Vector_2" stroke="#4F7EF5" strokeLinecap="round" strokeWidth="1.34876" />
        </g>
        <defs>
          <clipPath id="clip0_0_286">
            <rect fill="white" height="17.9835" width="17.9835" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container26() {
  return (
    <div className="bg-[rgba(79,126,245,0.1)] content-stretch flex items-center justify-center relative rounded-[13px] shrink-0 size-[44px]" data-name="Container">
      <Icon7 />
    </div>
  );
}

function Paragraph9() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[#111827] text-[14px] whitespace-nowrap">Resume V2</p>
    </div>
  );
}

function Text6() {
  return (
    <div className="bg-[rgba(229,231,235,0.7)] content-stretch flex flex-col items-start px-[8px] py-[2px] relative rounded-[99px] shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium','Noto_Sans_SC:Medium',sans-serif] font-medium leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] whitespace-nowrap">归档</p>
    </div>
  );
}

function Container28() {
  return (
    <div className="content-stretch flex gap-[8px] items-center relative shrink-0 w-full" data-name="Container">
      <Paragraph9 />
      <Text6 />
    </div>
  );
}

function Paragraph10() {
  return (
    <div className="content-stretch flex flex-col h-[19px] items-start pt-[2px] relative shrink-0 w-[210px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">2026.05.15 · 补充用户研究案例</p>
    </div>
  );
}

function Container27() {
  return (
    <div className="content-stretch flex flex-[210_0_0] flex-col items-start min-w-px relative" data-name="Container">
      <Container28 />
      <Paragraph10 />
    </div>
  );
}

function Paragraph11() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] bg-clip-text font-['Inter:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[14px] text-[transparent] text-right whitespace-nowrap" style={{ backgroundImage: "linear-gradient(145.00797980144134deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }}>
        79%
      </p>
    </div>
  );
}

function Paragraph12() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-end pt-[2px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-right whitespace-nowrap">最高匹配</p>
    </div>
  );
}

function Container29() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[40px]" data-name="Container">
      <Paragraph11 />
      <Paragraph12 />
    </div>
  );
}

function Container25() {
  return (
    <div className="absolute backdrop-blur-[24px] bg-[rgba(255,255,255,0.75)] content-stretch flex gap-[12px] items-center left-0 p-[16px] top-0 w-[350px]" data-name="Container">
      <Container26 />
      <Container27 />
      <Container29 />
    </div>
  );
}

function SwipeableResumeCard() {
  return (
    <div className="h-[76px] overflow-clip relative rounded-[16px] shrink-0 w-full" data-name="SwipeableResumeCard">
      <Container24 />
      <Container25 />
    </div>
  );
}

function Icon8() {
  return (
    <div className="relative shrink-0 size-[17.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="17.9835" preserveAspectRatio="none" viewBox="0 0 17.9835 17.9835" width="17.9835">
        <g id="Icon">
          <path d={svgPaths.p269e2a00} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.64849" />
        </g>
      </svg>
    </div>
  );
}

function Button4() {
  return (
    <div className="content-stretch flex flex-[80_0_0] flex-col gap-[4px] h-full items-center justify-center min-w-px relative" style={{ backgroundImage: "linear-gradient(136.46880071438582deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Button">
      <Icon8 />
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[14px] not-italic relative shrink-0 text-[10px] text-center text-white whitespace-nowrap">设为当前</p>
    </div>
  );
}

function Icon9() {
  return (
    <div className="relative shrink-0 size-[17.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="17.9835" preserveAspectRatio="none" viewBox="0 0 17.9835 17.9835" width="17.9835">
        <g id="Icon">
          <path d={svgPaths.p30673340} id="Vector" stroke="white" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.49863" />
        </g>
      </svg>
    </div>
  );
}

function Button5() {
  return (
    <div className="bg-[#ff3b30] content-stretch flex flex-[80_0_0] flex-col gap-[4px] h-full items-center justify-center min-w-px relative" data-name="Button">
      <Icon9 />
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[14px] not-italic relative shrink-0 text-[10px] text-center text-white whitespace-nowrap">删除</p>
    </div>
  );
}

function Container30() {
  return (
    <div className="absolute content-stretch flex h-[76px] items-start left-[190.02px] top-0 w-[160px]" data-name="Container">
      <Button4 />
      <Button5 />
    </div>
  );
}

function Icon10() {
  return (
    <div className="relative shrink-0 size-[17.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="17.9835" preserveAspectRatio="none" viewBox="0 0 17.9835 17.9835" width="17.9835">
        <g clipPath="url(#clip0_0_274)" id="Icon">
          <path d={svgPaths.p1f922870} id="Vector" stroke="#6B7280" strokeWidth="1.34876" />
          <path d={svgPaths.pb2c3840} id="Vector_2" stroke="#6B7280" strokeLinecap="round" strokeWidth="1.34876" />
        </g>
        <defs>
          <clipPath id="clip0_0_274">
            <rect fill="white" height="17.9835" width="17.9835" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container32() {
  return (
    <div className="bg-[rgba(229,231,235,0.55)] content-stretch flex items-center justify-center relative rounded-[13px] shrink-0 size-[44px]" data-name="Container">
      <Icon10 />
    </div>
  );
}

function Paragraph13() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[#111827] text-[14px] whitespace-nowrap">Resume V1</p>
    </div>
  );
}

function Text7() {
  return (
    <div className="bg-[rgba(229,231,235,0.7)] content-stretch flex flex-col items-start px-[8px] py-[2px] relative rounded-[99px] shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium','Noto_Sans_SC:Medium',sans-serif] font-medium leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] whitespace-nowrap">归档</p>
    </div>
  );
}

function Container34() {
  return (
    <div className="content-stretch flex gap-[8px] items-center relative shrink-0 w-full" data-name="Container">
      <Paragraph13 />
      <Text7 />
    </div>
  );
}

function Paragraph14() {
  return (
    <div className="content-stretch flex flex-col h-[19px] items-start pt-[2px] relative shrink-0 w-[210px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">2026.01.03 · 首次创建</p>
    </div>
  );
}

function Container33() {
  return (
    <div className="content-stretch flex flex-[210_0_0] flex-col items-start min-w-px relative" data-name="Container">
      <Container34 />
      <Paragraph14 />
    </div>
  );
}

function Paragraph15() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] bg-clip-text font-['Inter:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[14px] text-[transparent] text-right whitespace-nowrap" style={{ backgroundImage: "linear-gradient(145.88552705465875deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }}>
        68%
      </p>
    </div>
  );
}

function Paragraph16() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-end pt-[2px] relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-right whitespace-nowrap">最高匹配</p>
    </div>
  );
}

function Container35() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[40px]" data-name="Container">
      <Paragraph15 />
      <Paragraph16 />
    </div>
  );
}

function Container31() {
  return (
    <div className="absolute backdrop-blur-[24px] bg-[rgba(255,255,255,0.75)] content-stretch flex gap-[12px] items-center left-0 p-[16px] top-0 w-[350px]" data-name="Container">
      <Container32 />
      <Container33 />
      <Container35 />
    </div>
  );
}

function SwipeableResumeCard1() {
  return (
    <div className="h-[76px] overflow-clip relative rounded-[16px] shrink-0 w-full" data-name="SwipeableResumeCard">
      <Container30 />
      <Container31 />
    </div>
  );
}

function SwipeableResumeCardMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[10px] relative shrink-0 w-full" data-name="SwipeableResumeCard:margin">
      <SwipeableResumeCard1 />
    </div>
  );
}

function Container23() {
  return (
    <div className="content-stretch flex flex-col h-[174px] items-start pt-[12px] relative shrink-0 w-[350px]" data-name="Container">
      <SwipeableResumeCard />
      <SwipeableResumeCardMargin />
    </div>
  );
}

function Container22() {
  return (
    <div className="content-stretch flex flex-col h-[211px] items-start pt-[20px] relative shrink-0 w-[350px]" data-name="Container">
      <Paragraph8 />
      <Container23 />
    </div>
  );
}

function Container5() {
  return (
    <div className="absolute content-stretch flex flex-col h-[766px] items-start left-0 overflow-clip pb-[96px] px-[20px] right-0 top-[45px]" data-name="Container">
      <Container6 />
      <Container22 />
    </div>
  );
}

function Icon11() {
  return (
    <div className="relative shrink-0 size-[21.988px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.9884" preserveAspectRatio="none" viewBox="0 0 21.9884 21.9884" width="21.9884">
        <g id="Icon">
          <path d={svgPaths.p3d09f00} id="Vector" stroke="white" strokeLinecap="round" strokeWidth="2.19884" />
        </g>
      </svg>
    </div>
  );
}

function Button6() {
  return (
    <div className="absolute content-stretch drop-shadow-[0px_8px_12px_rgba(79,126,245,0.4)] flex items-center justify-center left-[314.02px] rounded-[28px] size-[56px] top-[726.77px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Button">
      <Icon11 />
    </div>
  );
}

function FillShadow() {
  return (
    <div className="absolute inset-0 rounded-[34px] shadow-[1.25px_0px_0px_-0.75px_#dbdbdb,-1.25px_0px_0px_-0.75px_#dbdbdb,0px_0px_0px_0.5px_#dbdbdb,0px_8px_48px_0px_rgba(0,0,0,0.25)]" data-name="Fill + Shadow">
      <div aria-hidden className="absolute inset-0 pointer-events-none rounded-[34px]">
        <div className="absolute bg-[rgba(255,255,255,0.7)] inset-0 mix-blend-lighten rounded-[34px]" />
        <div className="absolute bg-[rgba(191,191,191,0.1)] inset-0 mix-blend-darken rounded-[34px]" />
      </div>
    </div>
  );
}

function GlassEffect() {
  return (
    <div className="absolute inset-0 pointer-events-none rounded-[34px]" data-name="Glass Effect">
      <div aria-hidden className="absolute bg-white inset-0 mix-blend-multiply rounded-[34px]" />
      <div className="absolute inset-0 rounded-[inherit] shadow-[inset_0px_40px_10px_-40px_#282828,inset_0px_-40px_10px_-40px_#282828]" />
    </div>
  );
}

function Container37() {
  return <div className="bg-[rgba(209,213,219,0.8)] h-[4px] relative rounded-[40822700px] shrink-0 w-[40px]" data-name="Container" />;
}

function ContainerMargin() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-center justify-end relative shrink-0 w-full" data-name="Container:margin">
      <Container37 />
    </div>
  );
}

function Heading1() {
  return (
    <div className="content-stretch flex flex-col h-[30px] items-center pt-[4px] relative shrink-0 w-[340px]" data-name="Heading 3">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[25.5px] not-italic relative shrink-0 text-[#111827] text-[17px] text-center whitespace-nowrap">导入新简历</p>
    </div>
  );
}

function ParagraphMargin() {
  return (
    <div className="content-stretch flex flex-col items-center pt-[16px] relative shrink-0 w-full" data-name="Paragraph:margin">
      <div className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[0] not-italic relative shrink-0 text-[#6b7280] text-[13px] text-center w-[340px]">
        <p className="leading-[20px] mb-0">从手机文件选择 PDF 或 Word 简历，</p>
        <p className="leading-[20px]">Careerly 会自动解析。</p>
      </div>
    </div>
  );
}

function Icon12() {
  return (
    <div className="relative shrink-0 size-[21.994px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.994" preserveAspectRatio="none" viewBox="0 0 21.994 21.994" width="21.994">
        <g id="Icon">
          <path d={svgPaths.p42cc200} id="Vector" stroke="#111827" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.64955" />
        </g>
      </svg>
    </div>
  );
}

function Paragraph17() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[21px] not-italic relative shrink-0 text-[#4f7ef5] text-[14px] whitespace-nowrap">从文件选择</p>
    </div>
  );
}

function Paragraph18() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">支持 PDF / DOCX</p>
    </div>
  );
}

function Container39() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[89px]" data-name="Container">
      <Paragraph17 />
      <Paragraph18 />
    </div>
  );
}

function Frame() {
  return (
    <div className="content-stretch flex gap-[21px] items-center relative shrink-0">
      <Icon12 />
      <Container39 />
    </div>
  );
}

function Button7() {
  return (
    <div className="bg-[rgba(79,126,245,0.08)] border-[1.244px] border-[rgba(79,126,245,0.2)] border-solid content-stretch flex items-center px-[20px] py-[10px] relative rounded-[16px] shrink-0 w-[340px]" data-name="Button">
      <Frame />
    </div>
  );
}

function Paragraph19() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[21px] not-italic relative shrink-0 text-[#373b4d] text-[14px] whitespace-nowrap">拍照上传</p>
    </div>
  );
}

function Paragraph20() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">拍摄简历照片</p>
    </div>
  );
}

function Container40() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[64px] top-[10px] w-[83px]" data-name="Container">
      <Paragraph19 />
      <Paragraph20 />
    </div>
  );
}

function Button8() {
  return (
    <div className="absolute bg-[rgba(229,231,235,0.4)] border-[1.244px] border-[rgba(0,0,0,0)] border-solid h-[61px] left-[-0.45px] rounded-[16px] top-[9.64px] w-[340px]" data-name="Button">
      <div className="absolute h-[15px] left-[21px] top-[21.5px] w-[19px]" data-name="Vector">
        <div className="absolute inset-[-5.5%_-4.34%]">
          <svg className="block size-full" fill="none" height="16.65" preserveAspectRatio="none" viewBox="0 0 20.65 16.65" width="20.65">
            <path d={svgPaths.p9948180} id="Vector" stroke="black" strokeLinecap="round" strokeWidth="1.65" />
          </svg>
        </div>
      </div>
      <Container40 />
    </div>
  );
}

function ButtonMargin() {
  return (
    <div className="h-[68px] relative shrink-0 w-[340px]" data-name="Button:margin">
      <Button8 />
    </div>
  );
}

function Icon13() {
  return <div className="absolute left-0 size-[13.994px] top-[20.76px]" data-name="Icon" />;
}

function Paragraph21() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[21px] not-italic relative shrink-0 text-[#373b4d] text-[14px] whitespace-nowrap">粘贴文本</p>
    </div>
  );
}

function Paragraph22() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">直接粘贴简历内容</p>
    </div>
  );
}

function Container41() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[62.99px] top-[8.76px] w-[88px]" data-name="Container">
      <Paragraph21 />
      <Paragraph22 />
    </div>
  );
}

function Button9() {
  return (
    <div className="absolute bg-[rgba(229,231,235,0.4)] border-[1.244px] border-[rgba(0,0,0,0)] border-solid h-[58px] left-0 rounded-[16px] top-[10px] w-[340px]" data-name="Button">
      <Icon13 />
      <div className="absolute inset-[calc(31.3%-0.47px)_calc(88.37%+0.95px)_calc(41.12%-0.22px)_calc(6.93%-1.07px)]" data-name="Vector">
        <div className="absolute inset-[-5.16%]">
          <svg className="block size-full" fill="none" height="17.65" preserveAspectRatio="none" viewBox="0 0 17.65 17.65" width="17.65">
            <path d={svgPaths.p21a8c680} id="Vector" stroke="#111827" strokeLinecap="round" strokeWidth="1.65" />
          </svg>
        </div>
      </div>
      <Container41 />
    </div>
  );
}

function ButtonMargin1() {
  return (
    <div className="h-[68px] relative shrink-0 w-[340px]" data-name="Button:margin">
      <Button9 />
    </div>
  );
}

function Container38() {
  return (
    <div className="content-stretch flex flex-col h-[226px] items-start py-[16px] relative shrink-0 w-[340px]" data-name="Container">
      <Button7 />
      <ButtonMargin />
      <ButtonMargin1 />
    </div>
  );
}

function ContainerMargin1() {
  return (
    <div className="content-stretch flex flex-col h-[304px] items-center pt-[8px] relative shrink-0 w-full" data-name="Container:margin">
      <Heading1 />
      <ParagraphMargin />
      <Container38 />
    </div>
  );
}

function Button10() {
  return (
    <div className="bg-[rgba(55,59,77,0.87)] content-stretch flex h-[48px] items-center justify-center relative rounded-[99px] shrink-0 w-[340px]" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[21px] not-italic relative shrink-0 text-[14px] text-center text-white whitespace-nowrap">取消</p>
    </div>
  );
}

function ButtonMargin2() {
  return (
    <div className="content-stretch flex flex-col h-[87px] items-start pt-[10px] relative shrink-0" data-name="Button:margin">
      <Button10 />
    </div>
  );
}

function Container42() {
  return (
    <div className="content-stretch flex flex-col h-[126px] items-start pt-[20px] relative shrink-0 w-[340px]" data-name="Container">
      <ButtonMargin2 />
    </div>
  );
}

function MenuItems() {
  return (
    <div className="relative shrink-0 w-full" data-name="Menu Items">
      <div className="content-stretch flex flex-col items-center px-[16px] relative size-full">
        <ContainerMargin />
        <ContainerMargin1 />
        <Container42 />
        <div className="h-[40px] relative shrink-0 w-full" data-name="Item">
          <div className="flex flex-row items-center size-full">
            <div className="content-stretch flex gap-[6px] items-center pl-[6px] pr-[8px] relative size-full" />
          </div>
        </div>
      </div>
    </div>
  );
}

function Container36() {
  return (
    <div className="absolute backdrop-blur-[6px] bg-[rgba(0,0,0,0.4)] content-stretch flex h-[811px] items-end left-0 top-0" data-name="Container">
      <div className="h-[451px] relative shrink-0 w-[389px]" data-name="Menu">
        <div className="flex flex-col items-center size-full">
          <div className="content-stretch flex flex-col items-center py-[10px] relative size-full">
            <FillShadow />
            <GlassEffect />
            <MenuItems />
          </div>
        </div>
      </div>
    </div>
  );
}

function Container4() {
  return (
    <div className="h-[811px] overflow-clip relative shrink-0 w-[390px]" data-name="Container">
      <TopBar />
      <Container5 />
      <Button6 />
      <Container36 />
    </div>
  );
}

function Container3() {
  return (
    <div className="content-stretch flex flex-[810.519_0_0] flex-col items-start min-h-px overflow-clip relative w-full" data-name="Container">
      <Container4 />
    </div>
  );
}

function Container() {
  return (
    <div className="absolute content-stretch flex flex-col h-[843.998px] items-start left-[5.95px] max-h-[844px] max-w-[390px] overflow-clip top-[15.36px] w-[389.998px]" style={{ backgroundImage: "linear-gradient(110.29450506932487deg, rgb(220, 233, 251) 11.492%, rgb(229, 220, 250) 46.146%, rgb(251, 233, 241) 88.517%)" }} data-name="Container">
      <Container1 />
      <Container3 />
    </div>
  );
}

function App() {
  return (
    <div className="bg-[#d2def0] h-[874.715px] relative shrink-0 w-[401.896px]" data-name="App">
      <Container />
    </div>
  );
}

export default function CareerlyAppInterfaceDesignCopy() {
  return (
    <div className="bg-white content-stretch flex flex-col items-start relative size-full" data-name="Careerly App Interface Design (Copy)">
      <App />
    </div>
  );
}