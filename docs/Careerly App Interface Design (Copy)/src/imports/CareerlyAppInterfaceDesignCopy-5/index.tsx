import svgPaths from "./svg-thbw4v9ls1";

function Text() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:SemiBold',sans-serif] font-semibold leading-[19.5px] relative shrink-0 text-[#6b7280] text-[13px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        9:41
      </p>
    </div>
  );
}

function Icon() {
  return (
    <div className="h-[11.995px] relative shrink-0 w-[15.987px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.995" preserveAspectRatio="none" viewBox="0 0 15.987 11.995" width="15.987">
        <g clipPath="url(#clip0_0_41)" id="Icon">
          <path d={svgPaths.p5b1c2f0} fill="#6B7280" id="Vector" />
          <path d={svgPaths.pfa93380} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p2cd646f0} fill="#111827" id="Vector_3" />
          <path d={svgPaths.p10337c00} fill="#111827" id="Vector_4" />
        </g>
        <defs>
          <clipPath id="clip0_0_41">
            <rect fill="white" height="11.995" width="15.987" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Icon1() {
  return (
    <div className="h-[11.995px] relative shrink-0 w-[17.983px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.995" preserveAspectRatio="none" viewBox="0 0 17.983 11.995" width="17.983">
        <g clipPath="url(#clip0_0_37)" id="Icon">
          <path d={svgPaths.p30c54b00} id="Vector" stroke="#6B7280" strokeWidth="0.999056" />
          <path d={svgPaths.p2391db00} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p20ca00c0} fill="#111827" id="Vector_3" />
        </g>
        <defs>
          <clipPath id="clip0_0_37">
            <rect fill="white" height="11.995" width="17.983" />
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

function FillShadow() {
  return (
    <div className="absolute inset-0 rounded-[1000px] shadow-[1.25px_0px_0px_-0.75px_#d0d0d0,-1.25px_0px_0px_-0.75px_#d0d0d0,0px_0px_0px_0.5px_#e8e8e8,0px_8px_15px_0px_rgba(0,0,0,0.02)]" data-name="Fill + Shadow">
      <div aria-hidden className="absolute inset-0 pointer-events-none rounded-[1000px]">
        <div className="absolute inset-0 rounded-[1000px]" style={{ backgroundImage: "linear-gradient(90deg, rgba(255, 255, 255, 0.25) 0%, rgba(255, 255, 255, 0.25) 100%), linear-gradient(90deg, rgba(0, 0, 0, 0.25) 0%, rgba(0, 0, 0, 0.25) 100%)" }} />
        <div className="absolute bg-[rgba(68,68,68,0.6)] inset-0 mix-blend-plus-lighter rounded-[1000px]" />
        <div className="absolute bg-[rgba(248,248,248,0.2)] inset-0 mix-blend-luminosity rounded-[1000px]" />
      </div>
    </div>
  );
}

function GlassEffect() {
  return (
    <div className="absolute inset-0 pointer-events-none rounded-[1000px]" data-name="Glass Effect">
      <div aria-hidden className="absolute bg-[rgba(0,0,0,0)] inset-0 rounded-[1000px]" />
      <div className="absolute inset-0 rounded-[inherit] shadow-[inset_0px_40px_10px_-40px_#282828,inset_0px_-40px_10px_-40px_#282828,inset_0px_40px_30px_-40px_#e6e6e6]" />
    </div>
  );
}

function Container6() {
  return (
    <div className="h-[24px] relative shrink-0 w-[268px]" data-name="Container">
      <p className="-translate-x-1/2 [word-break:break-word] absolute font-['Inter:Bold',sans-serif] font-bold leading-[0] left-[134.26px] not-italic text-[#111827] text-[16px] text-center top-[0.23px] whitespace-nowrap">
        <span className="font-['Roboto:Bold',sans-serif] leading-[24px]" style={{ fontVariationSettings: '"wdth" 100' }}>{`AI `}</span>
        <span className="font-['Noto_Sans_SC:Bold',sans-serif] leading-[24px]">正在分析</span>
      </p>
    </div>
  );
}

function Container7() {
  return <div className="h-0 relative shrink-0 w-[36px]" data-name="Container" />;
}

function Container5() {
  return (
    <div className="content-stretch flex items-center pb-[4px] pt-[16px] px-[16px] relative shrink-0 w-full" data-name="Container">
      <div className="h-[44px] min-w-[44px] relative rounded-[296px] shrink-0" data-name="Button Group">
        <div className="flex flex-row items-center justify-center min-w-[inherit] size-full">
          <div className="content-stretch flex gap-[12px] items-center justify-center min-w-[inherit] px-[2px] relative size-full">
            <div className="-translate-y-1/2 absolute h-[44px] left-0 right-0 top-1/2" data-name="BG">
              <FillShadow />
              <GlassEffect />
            </div>
            <div className="h-[36px] min-w-[36px] relative rounded-[100px] shrink-0" data-name="Text">
              <div className="flex flex-row items-center justify-center min-w-[inherit] size-full">
                <div className="content-stretch flex gap-[2px] items-center justify-center min-w-[inherit] px-[8px] relative size-full">
                  <div className="[word-break:break-word] flex flex-col font-['SF_Pro:Semibold',sans-serif] font-[590] justify-center leading-[0] relative shrink-0 text-[#08f] text-[17px] text-center whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100', fontFeatureSettings: '"ss16" 1' }}>
                    <p className="leading-[normal]">{`\u{100BF6}`}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <Container6 />
      <Container7 />
    </div>
  );
}

function Text1() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">正在分析</p>
    </div>
  );
}

function Text2() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:SemiBold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[16.5px] relative shrink-0 text-[#4f7ef5] text-[11px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        解析简历中
      </p>
    </div>
  );
}

function Container9() {
  return (
    <div className="bg-[rgba(79,126,245,0.08)] border-[1.217px] border-[rgba(79,126,245,0.15)] border-solid content-stretch flex gap-[6px] items-center px-[12px] py-[6px] relative rounded-[40822700px] self-stretch shrink-0" data-name="Container">
      <Text1 />
      <Text2 />
    </div>
  );
}

function Container8() {
  return (
    <div className="content-stretch flex items-start justify-center py-[8px] relative shrink-0 w-full" data-name="Container">
      <Container9 />
    </div>
  );
}

function Container13() {
  return <div className="absolute left-[-20.63px] opacity-0 rounded-[49782876px] size-[229.264px] top-[-20.63px]" style={{ backgroundImage: "url(\"data:image/svg+xml;utf8,<svg viewBox='0 0 229.26 229.26' xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='none'><rect x='0' y='0' height='100%' width='100%' fill='url(%23grad)' opacity='1'/><defs><radialGradient id='grad' gradientUnits='userSpaceOnUse' cx='0' cy='0' r='10' gradientTransform='matrix(0 -16.211 -16.211 0 114.63 114.63)'><stop stop-color='rgba(79,126,245,0.14)' offset='0'/><stop stop-color='rgba(79,126,245,0)' offset='0.65'/></radialGradient></defs></svg>\")" }} data-name="Container" />;
}

function Container14() {
  return <div className="absolute left-[15.42px] opacity-37 rounded-[43350444px] size-[157.164px] top-[15.42px]" style={{ backgroundImage: "url(\"data:image/svg+xml;utf8,<svg viewBox='0 0 157.16 157.16' xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='none'><rect x='0' y='0' height='100%' width='100%' fill='url(%23grad)' opacity='1'/><defs><radialGradient id='grad' gradientUnits='userSpaceOnUse' cx='0' cy='0' r='10' gradientTransform='matrix(0 -11.113 -11.113 0 78.582 78.582)'><stop stop-color='rgba(167,123,230,0.16)' offset='0'/><stop stop-color='rgba(167,123,230,0)' offset='0.65'/></radialGradient></defs></svg>\")" }} data-name="Container" />;
}

function Container16() {
  return <div className="absolute bg-[rgba(255,255,255,0.42)] blur-[5.328px] h-[27.708px] left-[23.45px] rounded-[17.184px] top-[19.17px] w-[42.628px]" data-name="Container" />;
}

function Container17() {
  return <div className="absolute bg-[rgba(255,255,255,0.18)] blur-[4.263px] h-[14.92px] left-[98.04px] rounded-[8.916px] top-[102.31px] w-[21.314px]" data-name="Container" />;
}

function Container15() {
  return (
    <div className="absolute blur-[0.533px] left-[23.66px] overflow-clip rounded-[70.336px] shadow-[0px_14.92px_46.89px_0px_rgba(79,126,245,0.28),0px_4.263px_19.182px_0px_rgba(167,123,230,0.18)] size-[140.671px] top-[23.66px]" data-name="Container">
      <div aria-hidden className="absolute inset-0 pointer-events-none rounded-[70.336px]" style={{ backgroundImage: "url(\"data:image/svg+xml;utf8,<svg viewBox='0 0 140.67 140.67' xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='none'><rect x='0' y='0' height='100%' width='100%' fill='url(%23grad)' opacity='1'/><defs><radialGradient id='grad' gradientUnits='userSpaceOnUse' cx='0' cy='0' r='10' gradientTransform='matrix(0 -12.535 -12.535 0 53.455 50.642)'><stop stop-color='rgba(196,168,246,0.97)' offset='0'/><stop stop-color='rgba(153,158,247,0.945)' offset='0.22'/><stop stop-color='rgba(110,148,248,0.92)' offset='0.44'/><stop stop-color='rgba(79,126,245,0.88)' offset='0.68'/><stop stop-color='rgba(106,148,249,0.8)' offset='0.84'/><stop stop-color='rgba(140,175,255,0.72)' offset='1'/></radialGradient></defs></svg>\")" }} />
      <Container16 />
      <Container17 />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_3.197px_10.657px_0px_rgba(255,255,255,0.38)]" />
    </div>
  );
}

function Container12() {
  return (
    <div className="relative shrink-0 size-[188px]" data-name="Container">
      <Container13 />
      <Container14 />
      <Container15 />
    </div>
  );
}

function Text3() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[48px] relative shrink-0 text-[#111827] text-[48px] tracking-[-2px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        36
      </p>
    </div>
  );
}

function Text4() {
  return (
    <div className="content-stretch flex flex-col h-[28px] items-start pb-[6px] relative shrink-0 w-[19px]" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[22px] relative shrink-0 text-[#6b7280] text-[22px] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        %
      </p>
    </div>
  );
}

function Container18() {
  return (
    <div className="content-stretch flex gap-[2px] h-[58px] items-end pb-[6px] pt-[4px] relative shrink-0 w-[83px]" data-name="Container">
      <Text3 />
      <Text4 />
    </div>
  );
}

function Container11() {
  return (
    <div className="absolute content-stretch flex flex-col items-center left-[20px] pb-[20px] pt-[12px] right-[20px] top-0" data-name="Container">
      <Container12 />
      <Container18 />
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[19.5px] relative shrink-0 text-[#6b7280] text-[13px] text-center whitespace-nowrap">正在认识</p>
    </div>
  );
}

function PlaceholderForAnalysisProcessing() {
  return <div className="absolute h-[325px] left-[20px] right-[20px] top-[298px]" data-name="Placeholder for AnalysisProcessing" />;
}

function Paragraph() {
  return (
    <div className="content-stretch flex flex-col h-[37px] items-start pb-[4px] pt-[16px] px-[20px] relative shrink-0 w-[348px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[16.5px] relative shrink-0 text-[#6b7280] text-[11px] tracking-[0.44px] whitespace-nowrap">分析进度</p>
    </div>
  );
}

function Icon2() {
  return (
    <div className="relative shrink-0 size-[13.991px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="13.991" preserveAspectRatio="none" viewBox="0 0 13.991 13.991" width="13.991">
        <g id="Icon">
          <path d={svgPaths.p60cb240} id="Vector" stroke="#34C759" strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.4574" />
        </g>
      </svg>
    </div>
  );
}

function Container23() {
  return (
    <div className="bg-[rgba(52,199,89,0.14)] content-stretch flex items-center justify-center relative rounded-[14px] shrink-0 size-[28px]" data-name="Container">
      <Icon2 />
    </div>
  );
}

function Container24() {
  return <div className="bg-[rgba(52,199,89,0.28)] h-[20px] min-h-[20px] relative rounded-[1px] shrink-0 w-[2px]" data-name="Container" />;
}

function ContainerMargin() {
  return (
    <div className="content-stretch flex flex-[26_0_0] flex-col items-start min-h-px py-[3px] relative" data-name="Container:margin">
      <Container24 />
    </div>
  );
}

function Container22() {
  return (
    <div className="content-stretch flex flex-col h-[54px] items-center relative shrink-0 w-[28px]" data-name="Container">
      <Container23 />
      <ContainerMargin />
    </div>
  );
}

function Paragraph1() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[19.25px] relative shrink-0 text-[#34c759] text-[14px] whitespace-nowrap">岗位需求解析</p>
    </div>
  );
}

function Text5() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-start pt-[2px] relative shrink-0 w-[65px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[0] not-italic relative shrink-0 text-[#34c759] text-[10px] whitespace-nowrap">
        <span className="font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[15px]">已完成</span>
        <span className="font-['Roboto:SemiBold',sans-serif] leading-[15px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` · 100%`}</span>
      </p>
    </div>
  );
}

function Container26() {
  return (
    <div className="content-stretch flex items-start justify-between relative shrink-0 w-full" data-name="Container">
      <Paragraph1 />
      <Text5 />
    </div>
  );
}

function Paragraph2() {
  return (
    <div className="content-stretch flex flex-col h-[20px] items-start pt-[2px] relative shrink-0 w-[268px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[0] not-italic relative shrink-0 text-[11px] text-[rgba(160,163,172,0.9)] whitespace-nowrap">
        <span className="font-['Roboto:Regular',sans-serif] leading-[17.875px]" style={{ fontVariationSettings: '"wdth" 100' }}>{`AI `}</span>
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[17.875px]">提取核心职责与技能要求</span>
      </p>
    </div>
  );
}

function Container25() {
  return (
    <div className="content-stretch flex flex-[268_0_0] flex-col items-start min-w-px pb-[14px] relative" data-name="Container">
      <Container26 />
      <Paragraph2 />
    </div>
  );
}

function Container21() {
  return (
    <div className="content-stretch flex gap-[12px] items-start relative shrink-0 w-[308px]" data-name="Container">
      <Container22 />
      <Container25 />
    </div>
  );
}

function Text6() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[16.5px] relative shrink-0 text-[11px] text-white whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        2
      </p>
    </div>
  );
}

function Container29() {
  return (
    <div className="content-stretch drop-shadow-[0px_0px_0px_rgba(79,126,245,0)] flex items-center justify-center relative rounded-[14px] shrink-0 size-[28px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container">
      <Text6 />
    </div>
  );
}

function Container30() {
  return <div className="bg-[rgba(229,231,235,0.7)] h-[31px] min-h-[20px] relative rounded-[1px] shrink-0 w-[2px]" data-name="Container" />;
}

function ContainerMargin1() {
  return (
    <div className="content-stretch flex flex-[37_0_0] flex-col items-start min-h-px py-[3px] relative" data-name="Container:margin">
      <Container30 />
    </div>
  );
}

function Container28() {
  return (
    <div className="content-stretch flex flex-col h-[65px] items-center relative shrink-0 w-[28px]" data-name="Container">
      <Container29 />
      <ContainerMargin1 />
    </div>
  );
}

function Paragraph3() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[19.25px] relative shrink-0 text-[#111827] text-[14px] whitespace-nowrap">简历信息解析</p>
    </div>
  );
}

function Text7() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-start pt-[2px] relative shrink-0 w-[60px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[0] not-italic relative shrink-0 text-[#4f7ef5] text-[10px] whitespace-nowrap">
        <span className="font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[15px]">进行中</span>
        <span className="font-['Roboto:SemiBold',sans-serif] leading-[15px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` · 80%`}</span>
      </p>
    </div>
  );
}

function Container32() {
  return (
    <div className="content-stretch flex items-start justify-between relative shrink-0 w-full" data-name="Container">
      <Paragraph3 />
      <Text7 />
    </div>
  );
}

function Paragraph4() {
  return (
    <div className="content-stretch flex flex-col h-[20px] items-start pt-[2px] relative shrink-0 w-[268px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular',sans-serif] font-normal leading-[0] not-italic relative shrink-0 text-[11px] text-[rgba(160,163,172,0.9)] whitespace-nowrap">
        <span className="font-['Roboto:Regular',sans-serif] leading-[17.875px]" style={{ fontVariationSettings: '"wdth" 100' }}>{`AI `}</span>
        <span className="font-['Noto_Sans_SC:Regular',sans-serif] leading-[17.875px]">提取经历、项目与能力证据</span>
      </p>
    </div>
  );
}

function Container34() {
  return <div className="h-[4px] relative rounded-[40822700px] shrink-0 w-[170px]" style={{ backgroundImage: "linear-gradient(178.6521127198014deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container" />;
}

function Container33() {
  return (
    <div className="bg-[rgba(229,231,235,0.7)] content-stretch flex flex-col h-[4px] items-start overflow-clip relative rounded-[40822700px] shrink-0 w-full" data-name="Container">
      <Container34 />
    </div>
  );
}

function ContainerMargin2() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[8px] relative shrink-0 w-full" data-name="Container:margin">
      <Container33 />
    </div>
  );
}

function Container31() {
  return (
    <div className="content-stretch flex flex-[268_0_0] flex-col items-start min-w-px pb-[14px] relative" data-name="Container">
      <Container32 />
      <Paragraph4 />
      <ContainerMargin2 />
    </div>
  );
}

function Container27() {
  return (
    <div className="content-stretch flex gap-[12px] items-start relative shrink-0 w-[308px]" data-name="Container">
      <Container28 />
      <Container31 />
    </div>
  );
}

function Text8() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[16.5px] relative shrink-0 text-[11px] text-[rgba(156,163,175,0.75)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        3
      </p>
    </div>
  );
}

function Container37() {
  return (
    <div className="bg-[rgba(229,231,235,0.55)] content-stretch flex items-center justify-center relative rounded-[14px] shrink-0 size-[28px]" data-name="Container">
      <Text8 />
    </div>
  );
}

function Container38() {
  return <div className="bg-[rgba(229,231,235,0.7)] h-[20px] min-h-[20px] relative rounded-[1px] shrink-0 w-[2px]" data-name="Container" />;
}

function ContainerMargin3() {
  return (
    <div className="content-stretch flex flex-[26_0_0] flex-col items-start min-h-px py-[3px] relative" data-name="Container:margin">
      <Container38 />
    </div>
  );
}

function Container36() {
  return (
    <div className="content-stretch flex flex-col h-[54px] items-center relative shrink-0 w-[28px]" data-name="Container">
      <Container37 />
      <ContainerMargin3 />
    </div>
  );
}

function Paragraph5() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[19.25px] relative shrink-0 text-[#6b7280] text-[14px] whitespace-nowrap">能力匹配分析</p>
    </div>
  );
}

function Text9() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-start pt-[2px] relative shrink-0 w-[30px]" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[15px] relative shrink-0 text-[#b9babe] text-[10px] whitespace-nowrap">等待中</p>
    </div>
  );
}

function Container40() {
  return (
    <div className="content-stretch flex items-start justify-between relative shrink-0 w-full" data-name="Container">
      <Paragraph5 />
      <Text9 />
    </div>
  );
}

function Paragraph6() {
  return (
    <div className="content-stretch flex flex-col h-[20px] items-start pt-[2px] relative shrink-0 w-[268px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[17.875px] relative shrink-0 text-[11px] text-[rgba(160,163,172,0.9)] whitespace-nowrap">将简历能力与岗位要求深度匹配</p>
    </div>
  );
}

function Container39() {
  return (
    <div className="content-stretch flex flex-[268_0_0] flex-col items-start min-w-px pb-[14px] relative" data-name="Container">
      <Container40 />
      <Paragraph6 />
    </div>
  );
}

function Container35() {
  return (
    <div className="content-stretch flex gap-[12px] items-start relative shrink-0 w-[308px]" data-name="Container">
      <Container36 />
      <Container39 />
    </div>
  );
}

function Text10() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[16.5px] relative shrink-0 text-[11px] text-[rgba(156,163,175,0.75)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        4
      </p>
    </div>
  );
}

function Container43() {
  return (
    <div className="bg-[rgba(229,231,235,0.55)] content-stretch flex items-center justify-center relative rounded-[14px] shrink-0 size-[28px]" data-name="Container">
      <Text10 />
    </div>
  );
}

function Container44() {
  return <div className="bg-[rgba(229,231,235,0.7)] h-[20px] min-h-[20px] relative rounded-[1px] shrink-0 w-[2px]" data-name="Container" />;
}

function ContainerMargin4() {
  return (
    <div className="content-stretch flex flex-[26_0_0] flex-col items-start min-h-px py-[3px] relative" data-name="Container:margin">
      <Container44 />
    </div>
  );
}

function Container42() {
  return (
    <div className="content-stretch flex flex-col h-[54px] items-center relative shrink-0 w-[28px]" data-name="Container">
      <Container43 />
      <ContainerMargin4 />
    </div>
  );
}

function Paragraph7() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[0] not-italic relative shrink-0 text-[#6b7280] text-[14px] whitespace-nowrap">
        <span className="font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[19.25px]">识别能力</span>
        <span className="font-['Roboto:SemiBold',sans-serif] leading-[19.25px]" style={{ fontVariationSettings: '"wdth" 100' }}>{` Gap`}</span>
      </p>
    </div>
  );
}

function Text11() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-start pt-[2px] relative shrink-0 w-[30px]" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[15px] relative shrink-0 text-[#b9babe] text-[10px] whitespace-nowrap">等待中</p>
    </div>
  );
}

function Container46() {
  return (
    <div className="content-stretch flex items-start justify-between relative shrink-0 w-full" data-name="Container">
      <Paragraph7 />
      <Text11 />
    </div>
  );
}

function Paragraph8() {
  return (
    <div className="content-stretch flex flex-col h-[20px] items-start pt-[2px] relative shrink-0 w-[268px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[17.875px] relative shrink-0 text-[11px] text-[rgba(160,163,172,0.9)] whitespace-nowrap">分析与岗位要求之间的成长空间</p>
    </div>
  );
}

function Container45() {
  return (
    <div className="content-stretch flex flex-[268_0_0] flex-col items-start min-w-px pb-[14px] relative" data-name="Container">
      <Container46 />
      <Paragraph8 />
    </div>
  );
}

function Container41() {
  return (
    <div className="content-stretch flex gap-[12px] items-start relative shrink-0 w-[308px]" data-name="Container">
      <Container42 />
      <Container45 />
    </div>
  );
}

function Text12() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Roboto:Bold',sans-serif] font-bold leading-[16.5px] relative shrink-0 text-[11px] text-[rgba(156,163,175,0.75)] whitespace-nowrap" style={{ fontVariationSettings: '"wdth" 100' }}>
        5
      </p>
    </div>
  );
}

function Container49() {
  return (
    <div className="bg-[rgba(229,231,235,0.55)] content-stretch flex items-center justify-center relative rounded-[14px] shrink-0 size-[28px]" data-name="Container">
      <Text12 />
    </div>
  );
}

function Container48() {
  return (
    <div className="content-stretch flex flex-col h-full items-center relative shrink-0 w-[28px]" data-name="Container">
      <Container49 />
    </div>
  );
}

function Paragraph9() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[19.25px] relative shrink-0 text-[#6b7280] text-[14px] whitespace-nowrap">生成分析报告</p>
    </div>
  );
}

function Text13() {
  return (
    <div className="content-stretch flex flex-col h-[17px] items-start pt-[2px] relative shrink-0 w-[30px]" data-name="Text">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[15px] relative shrink-0 text-[#b9babe] text-[10px] whitespace-nowrap">等待中</p>
    </div>
  );
}

function Container51() {
  return (
    <div className="content-stretch flex items-start justify-between relative shrink-0 w-full" data-name="Container">
      <Paragraph9 />
      <Text13 />
    </div>
  );
}

function Paragraph10() {
  return (
    <div className="content-stretch flex flex-col h-[20px] items-start pt-[2px] relative shrink-0 w-[268px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Noto_Sans_SC:Regular',sans-serif] font-normal leading-[17.875px] relative shrink-0 text-[11px] text-[rgba(160,163,172,0.9)] whitespace-nowrap">整理匹配度、排名与改进建议</p>
    </div>
  );
}

function Container50() {
  return (
    <div className="content-stretch flex flex-[268_0_0] flex-col h-full items-start min-w-px relative" data-name="Container">
      <Container51 />
      <Paragraph10 />
    </div>
  );
}

function Container47() {
  return (
    <div className="content-stretch flex gap-[12px] h-[39px] items-start relative shrink-0 w-[308px]" data-name="Container">
      <Container48 />
      <Container50 />
    </div>
  );
}

function Container20() {
  return (
    <div className="content-stretch flex flex-col items-start pb-[16px] pt-[4px] px-[20px] relative shrink-0 w-[348px]" data-name="Container">
      <Container21 />
      <Container27 />
      <Container35 />
      <Container41 />
      <Container47 />
    </div>
  );
}

function Container19() {
  return (
    <div className="backdrop-blur-[10px] bg-[rgba(255,255,255,0.62)] border-[1.217px] border-[rgba(255,255,255,0.65)] border-solid content-stretch flex flex-col h-[325px] items-start overflow-clip relative rounded-[16px] shrink-0 w-full" data-name="Container">
      <Paragraph />
      <Container20 />
    </div>
  );
}

function PrimaryBtn() {
  return (
    <div className="drop-shadow-[0px_8px_12px_rgba(79,126,245,0.3)] h-[48px] relative rounded-[99px] shrink-0 w-full" style={{ backgroundImage: "linear-gradient(172.20729636502307deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="PrimaryBtn">
      <p className="-translate-x-1/2 [word-break:break-word] absolute font-['Noto_Sans_SC:Bold',sans-serif] font-bold leading-[22.5px] left-[175px] text-[15px] text-center text-white top-[12.5px] whitespace-nowrap">退出分析</p>
    </div>
  );
}

function Frame() {
  return (
    <div className="absolute content-stretch flex flex-col gap-[13px] items-start left-[19.26px] top-[297.59px] w-[350.741px]">
      <Container19 />
      <PrimaryBtn />
    </div>
  );
}

function Container10() {
  return (
    <div className="flex-[708_0_0] min-h-px overflow-clip relative w-full" data-name="Container">
      <Container11 />
      <PlaceholderForAnalysisProcessing />
      <Frame />
    </div>
  );
}

function Container4() {
  return (
    <div className="content-stretch flex flex-col h-[810px] items-start relative shrink-0 w-full" style={{ backgroundImage: "linear-gradient(111.0729547452385deg, rgb(220, 233, 251) 11.492%, rgb(229, 220, 250) 46.146%, rgb(251, 233, 241) 88.517%)" }} data-name="Container">
      <Container5 />
      <Container8 />
      <Container10 />
    </div>
  );
}

function Container3() {
  return (
    <div className="content-stretch flex flex-[810.491_0_0] flex-col items-start min-h-px relative w-full" data-name="Container">
      <Container4 />
    </div>
  );
}

function Container() {
  return (
    <div className="content-stretch flex flex-col h-[843.986px] items-start max-h-[844px] max-w-[390px] overflow-clip relative shrink-0 w-[390px]" style={{ backgroundImage: "linear-gradient(110.2948550978526deg, rgb(220, 233, 251) 11.492%, rgb(229, 220, 250) 46.146%, rgb(251, 233, 241) 88.517%)" }} data-name="Container">
      <Container1 />
      <Container3 />
    </div>
  );
}

function App() {
  return (
    <div className="bg-[#d2def0] content-stretch flex h-[873.526px] items-center justify-center relative shrink-0 w-[401.481px]" data-name="App">
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