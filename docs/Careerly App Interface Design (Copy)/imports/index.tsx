import svgPaths from "./svg-o1dqpa8tpq";

function Text() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold',sans-serif] font-semibold leading-[19.5px] not-italic relative shrink-0 text-[#6b7280] text-[13px] whitespace-nowrap">9:41</p>
    </div>
  );
}

function Icon() {
  return (
    <div className="h-[11.989px] relative shrink-0 w-[15.986px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.9892" preserveAspectRatio="none" viewBox="0 0 15.9856 11.9892" width="15.9856">
        <g clipPath="url(#clip0_0_22)" id="Icon">
          <path d={svgPaths.p26488100} fill="#6B7280" id="Vector" />
          <path d={svgPaths.p1bf69100} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p23d73640} fill="#111827" id="Vector_3" />
          <path d={svgPaths.p10b2c4f0} fill="#111827" id="Vector_4" />
        </g>
        <defs>
          <clipPath id="clip0_0_22">
            <rect fill="white" height="11.9892" width="15.9856" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Icon1() {
  return (
    <div className="h-[11.989px] relative shrink-0 w-[17.984px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="11.9892" preserveAspectRatio="none" viewBox="0 0 17.9838 11.9892" width="17.9838">
        <g clipPath="url(#clip0_0_15)" id="Icon">
          <path d={svgPaths.pcdf2200} id="Vector" stroke="#6B7280" strokeWidth="0.9991" />
          <path d={svgPaths.p1afa3b00} fill="#6B7280" id="Vector_2" />
          <path d={svgPaths.p34359b00} fill="#111827" id="Vector_3" />
        </g>
        <defs>
          <clipPath id="clip0_0_15">
            <rect fill="white" height="11.9892" width="17.9838" />
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
    <div className="absolute content-stretch flex h-[34px] items-center justify-between left-0 pb-[2px] pt-[12px] px-[24px] right-0 top-0" data-name="Container">
      <Text />
      <Container2 />
    </div>
  );
}

function Paragraph() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[350.031px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[18px] not-italic relative shrink-0 text-[#6b7280] text-[12px] whitespace-nowrap">分析</p>
    </div>
  );
}

function Heading() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[350.031px]" data-name="Heading 1">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[33px] not-italic relative shrink-0 text-[#111827] text-[22px] whitespace-nowrap">职业分析</p>
    </div>
  );
}

function Button() {
  return (
    <div className="bg-white content-stretch drop-shadow-[0px_2px_4px_rgba(79,126,245,0.12)] flex flex-[171.01_0_0] flex-col h-[35.986px] items-center justify-center min-w-px relative rounded-[14px]" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[19.5px] not-italic relative shrink-0 text-[#4f7ef5] text-[13px] text-center whitespace-nowrap">新建分析</p>
    </div>
  );
}

function Button1() {
  return (
    <div className="content-stretch flex flex-[171.028_0_0] flex-col h-[35.986px] items-center justify-center min-w-px relative rounded-[14px]" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[19.5px] not-italic relative shrink-0 text-[#6b7280] text-[13px] text-center whitespace-nowrap">历史分析</p>
    </div>
  );
}

function Container6() {
  return (
    <div className="bg-[rgba(79,126,245,0.08)] content-stretch flex items-start p-[4px] relative rounded-[16px] shrink-0 w-[350.031px]" data-name="Container">
      <Button />
      <Button1 />
    </div>
  );
}

function ContainerMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[12px] relative shrink-0" data-name="Container:margin">
      <Container6 />
    </div>
  );
}

function Container5() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-0 px-[20px] py-[12px] right-0 top-0" data-name="Container">
      <Paragraph />
      <Heading />
      <ContainerMargin />
    </div>
  );
}

function Paragraph1() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[20px] top-0 w-[350.031px]" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[19.5px] not-italic relative shrink-0 text-[#6b7280] text-[13px] whitespace-nowrap">基于你的职业经历，看看你与目标岗位的距离。</p>
    </div>
  );
}

function Icon2() {
  return (
    <div className="relative shrink-0 size-[15.986px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="15.9856" preserveAspectRatio="none" viewBox="0 0 15.9856 15.9856" width="15.9856">
        <g clipPath="url(#clip0_0_19)" id="Icon">
          <path d={svgPaths.p29b54000} id="Vector" stroke="white" strokeWidth="1.19892" />
          <path d={svgPaths.p34b5a400} id="Vector_2" stroke="white" strokeLinecap="round" strokeWidth="1.19892" />
        </g>
        <defs>
          <clipPath id="clip0_0_19">
            <rect fill="white" height="15.9856" width="15.9856" />
          </clipPath>
        </defs>
      </svg>
    </div>
  );
}

function Container9() {
  return (
    <div className="content-stretch flex items-center justify-center relative rounded-[12px] shrink-0 size-[39.982px]" style={{ backgroundImage: "linear-gradient(135deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container">
      <Icon2 />
    </div>
  );
}

function Paragraph2() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[#111827] text-[14px] whitespace-nowrap">当前简历</p>
    </div>
  );
}

function Paragraph3() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">Resume V3 · 2026.08.27 更新</p>
    </div>
  );
}

function Container10() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[152.899px]" data-name="Container">
      <Paragraph2 />
      <Paragraph3 />
    </div>
  );
}

function Container8() {
  return (
    <div className="content-stretch flex gap-[12px] items-center relative shrink-0" data-name="Container">
      <Container9 />
      <Container10 />
    </div>
  );
}

function Text1() {
  return (
    <div className="bg-[rgba(79,126,245,0.1)] content-stretch flex flex-col items-start px-[12px] py-[6px] relative rounded-[12px] shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[18px] not-italic relative shrink-0 text-[#4f7ef5] text-[12px] whitespace-nowrap">更换</p>
    </div>
  );
}

function AnalysisHome1() {
  return (
    <div className="content-stretch flex items-start justify-between relative shrink-0 w-[315.734px]" data-name="AnalysisHome">
      <Container8 />
      <Text1 />
    </div>
  );
}

function Paragraph4() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] bg-clip-text font-['Inter:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[14px] text-[transparent] text-center whitespace-nowrap" style={{ backgroundImage: "linear-gradient(138.81407483429035deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }}>
        5项
      </p>
    </div>
  );
}

function Paragraph5() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-center whitespace-nowrap">核心能力</p>
    </div>
  );
}

function Container11() {
  return (
    <div className="bg-[rgba(79,126,245,0.06)] content-stretch flex flex-[97.24_0_0] flex-col items-start min-w-px py-[8px] relative rounded-[12px]" data-name="Container">
      <Paragraph4 />
      <Paragraph5 />
    </div>
  );
}

function Paragraph6() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] bg-clip-text font-['Inter:Bold','Noto_Sans_JP:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[14px] text-[transparent] text-center whitespace-nowrap" style={{ backgroundImage: "linear-gradient(138.81407483429035deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }}>
        4段
      </p>
    </div>
  );
}

function Paragraph7() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-center whitespace-nowrap">经历</p>
    </div>
  );
}

function Container12() {
  return (
    <div className="bg-[rgba(79,126,245,0.06)] content-stretch flex flex-[97.258_0_0] flex-col items-start min-w-px py-[8px] relative rounded-[12px]" data-name="Container">
      <Paragraph6 />
      <Paragraph7 />
    </div>
  );
}

function Paragraph8() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] bg-clip-text font-['Inter:Bold','Noto_Sans_JP:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[14px] text-[transparent] text-center whitespace-nowrap" style={{ backgroundImage: "linear-gradient(138.81407483429035deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }}>
        6个
      </p>
    </div>
  );
}

function Paragraph9() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[15px] not-italic relative shrink-0 text-[#6b7280] text-[10px] text-center whitespace-nowrap">项目</p>
    </div>
  );
}

function Container13() {
  return (
    <div className="bg-[rgba(79,126,245,0.06)] content-stretch flex flex-[97.258_0_0] flex-col items-start min-w-px py-[8px] relative rounded-[12px]" data-name="Container">
      <Paragraph8 />
      <Paragraph9 />
    </div>
  );
}

function AnalysisHome2() {
  return (
    <div className="content-stretch flex gap-[12px] h-[64px] items-start pt-[12px] relative shrink-0 w-[315.734px]" data-name="AnalysisHome">
      <Container11 />
      <Container12 />
      <Container13 />
    </div>
  );
}

function Card() {
  return (
    <div className="backdrop-blur-[24px] bg-[rgba(255,255,255,0.68)] border-[1.163px] border-[rgba(255,255,255,0.55)] border-solid content-stretch flex flex-col items-start p-[16px] relative rounded-[24px] shadow-[0px_8px_32px_0px_rgba(79,126,245,0.08)] shrink-0" data-name="Card">
      <AnalysisHome1 />
      <AnalysisHome2 />
    </div>
  );
}

function CardMargin() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[20px] pt-[16px] top-[20px]" data-name="Card:margin">
      <Card />
    </div>
  );
}

function Paragraph10() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[21px] not-italic relative shrink-0 text-[#111827] text-[14px] whitespace-nowrap">目标岗位</p>
    </div>
  );
}

function Paragraph11() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Regular','Noto_Sans_JP:Regular','Noto_Sans_SC:Regular',sans-serif] font-normal leading-[16.5px] not-italic relative shrink-0 text-[#6b7280] text-[11px] whitespace-nowrap">已添加 4 个目标岗位</p>
    </div>
  );
}

function Container14() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[101.309px]" data-name="Container">
      <Paragraph10 />
      <Paragraph11 />
    </div>
  );
}

function Button2() {
  return (
    <div className="bg-[rgba(79,126,245,0.1)] content-stretch flex flex-col items-center justify-center relative rounded-[12px] shrink-0" data-name="Button">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[18px] not-italic relative shrink-0 text-[#4f7ef5] text-[12px] text-center whitespace-nowrap">管理</p>
    </div>
  );
}

function AnalysisHome3() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[315.734px]" data-name="AnalysisHome">
      <Container14 />
      <Button2 />
    </div>
  );
}

function Text2() {
  return (
    <div className="absolute bg-[rgba(79,126,245,0.08)] content-stretch flex flex-col h-[25.995px] items-start left-0 px-[12px] py-[4px] rounded-[39010100px] top-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium','Noto_Sans_SC:Medium',sans-serif] font-medium leading-[18px] not-italic relative shrink-0 text-[#4f7ef5] text-[12px] whitespace-nowrap">AI 产品经理</p>
    </div>
  );
}

function Text3() {
  return (
    <div className="absolute bg-[rgba(79,126,245,0.08)] content-stretch flex flex-col h-[25.995px] items-start left-[94.95px] px-[12px] py-[4px] rounded-[39010100px] top-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium','Noto_Sans_SC:Medium',sans-serif] font-medium leading-[18px] not-italic relative shrink-0 text-[#4f7ef5] text-[12px] whitespace-nowrap">产品经理</p>
    </div>
  );
}

function Text4() {
  return (
    <div className="absolute bg-[rgba(79,126,245,0.08)] content-stretch flex flex-col h-[25.995px] items-start left-[174.92px] px-[12px] py-[4px] rounded-[39010100px] top-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium','Noto_Sans_SC:Medium',sans-serif] font-medium leading-[18px] not-italic relative shrink-0 text-[#4f7ef5] text-[12px] whitespace-nowrap">数据产品经理</p>
    </div>
  );
}

function Text5() {
  return (
    <div className="absolute bg-[rgba(79,126,245,0.08)] content-stretch flex flex-col h-[25.995px] items-start left-0 px-[12px] py-[4px] rounded-[39010100px] top-[33.99px]" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium','Noto_Sans_SC:Medium',sans-serif] font-medium leading-[18px] not-italic relative shrink-0 text-[#4f7ef5] text-[12px] whitespace-nowrap">用户增长产品</p>
    </div>
  );
}

function AnalysisHome4() {
  return (
    <div className="h-[59.982px] relative shrink-0 w-[315.734px]" data-name="AnalysisHome">
      <Text2 />
      <Text3 />
      <Text4 />
      <Text5 />
    </div>
  );
}

function AnalysisHomeMargin() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[12px] relative shrink-0" data-name="AnalysisHome:margin">
      <AnalysisHome4 />
    </div>
  );
}

function Icon3() {
  return (
    <div className="relative shrink-0 size-[13.987px]" data-name="Icon">
      <svg className="absolute block inset-0 size-full" fill="none" height="13.9874" preserveAspectRatio="none" viewBox="0 0 13.9874 13.9874" width="13.9874">
        <g id="Icon">
          <path d={svgPaths.p18c8cc0} id="Vector" stroke="#4F7EF5" strokeLinecap="round" strokeWidth="1.28218" />
        </g>
      </svg>
    </div>
  );
}

function Text6() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[18px] not-italic relative shrink-0 text-[#4f7ef5] text-[12px] text-center whitespace-nowrap">添加目标岗位</p>
    </div>
  );
}

function AnalysisHome5() {
  return (
    <div className="border-[1.163px] border-[rgba(79,126,245,0.3)] border-dashed content-stretch flex gap-[8px] h-[35.986px] items-center justify-center relative rounded-[12px] shrink-0 w-[315.734px]" data-name="AnalysisHome">
      <Icon3 />
      <Text6 />
    </div>
  );
}

function AnalysisHomeMargin1() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[12px] relative shrink-0" data-name="AnalysisHome:margin">
      <AnalysisHome5 />
    </div>
  );
}

function Card1() {
  return (
    <div className="backdrop-blur-[24px] bg-[rgba(255,255,255,0.68)] border-[1.163px] border-[rgba(255,255,255,0.55)] border-solid content-stretch flex flex-col items-start p-[16px] relative rounded-[24px] shadow-[0px_8px_32px_0px_rgba(79,126,245,0.08)] shrink-0" data-name="Card">
      <AnalysisHome3 />
      <AnalysisHomeMargin />
      <AnalysisHomeMargin1 />
    </div>
  );
}

function CardMargin1() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[20px] pt-[16px] top-[174.31px]" data-name="Card:margin">
      <Card1 />
    </div>
  );
}

function Paragraph12() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[19.5px] not-italic relative shrink-0 text-[#4f7ef5] text-[13px] whitespace-nowrap">免费体验</p>
    </div>
  );
}

function Text7() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold',sans-serif] font-bold leading-[19.5px] not-italic relative shrink-0 text-[#4f7ef5] text-[13px] whitespace-nowrap">剩余 3 / 3 次</p>
    </div>
  );
}

function Container16() {
  return (
    <div className="content-stretch flex items-center justify-between relative shrink-0 w-[315.734px]" data-name="Container">
      <Paragraph12 />
      <Text7 />
    </div>
  );
}

function Container18() {
  return <div className="h-[5.995px] relative rounded-[39010100px] shrink-0 w-full" style={{ backgroundImage: "linear-gradient(178.9122987656557deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container" />;
}

function Container17() {
  return (
    <div className="bg-[rgba(229,231,235,0.8)] content-stretch flex flex-col h-[5.995px] items-start overflow-clip relative rounded-[39010100px] shrink-0 w-[315.734px]" data-name="Container">
      <Container18 />
    </div>
  );
}

function ContainerMargin2() {
  return (
    <div className="content-stretch flex flex-col items-start pt-[8px] relative shrink-0" data-name="Container:margin">
      <Container17 />
    </div>
  );
}

function Container15() {
  return (
    <div className="bg-[rgba(79,126,245,0.06)] border-[1.163px] border-[rgba(79,126,245,0.15)] border-solid content-stretch flex flex-col items-start px-[16px] py-[12px] relative rounded-[16px] shrink-0" data-name="Container">
      <Container16 />
      <ContainerMargin2 />
    </div>
  );
}

function ContainerMargin1() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[20px] pt-[16px] top-[382.6px]" data-name="Container:margin">
      <Container15 />
    </div>
  );
}

function PrimaryBtn() {
  return (
    <div className="content-stretch drop-shadow-[0px_8px_12px_rgba(79,126,245,0.3)] flex h-[47.993px] items-center justify-center relative rounded-[99px] shrink-0 w-[350.031px]" style={{ backgroundImage: "linear-gradient(172.1927757514838deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="PrimaryBtn">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold',sans-serif] font-bold leading-[22.5px] not-italic relative shrink-0 text-[15px] text-black text-center whitespace-nowrap">开始新分析</p>
    </div>
  );
}

function PrimaryBtnMargin() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[20px] py-[16px] top-[458.92px]" data-name="PrimaryBtn:margin">
      <PrimaryBtn />
    </div>
  );
}

function Container21() {
  return <div className="absolute bg-[rgba(255,255,255,0.08)] left-[254.03px] rounded-[39010100px] size-[127.994px] top-[-31.99px]" data-name="Container" />;
}

function Paragraph13() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Medium','Noto_Sans_JP:Medium',sans-serif] font-medium leading-[16.5px] not-italic relative shrink-0 text-[11px] text-[rgba(255,255,255,0.6)] whitespace-nowrap">最近一次分析</p>
    </div>
  );
}

function Paragraph14() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-bold leading-[22.5px] not-italic relative shrink-0 text-[15px] text-white whitespace-nowrap">2026.08.27 · 4 个岗位</p>
    </div>
  );
}

function Paragraph15() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[30px] not-italic relative shrink-0 text-[30px] text-right text-white whitespace-nowrap">86%</p>
    </div>
  );
}

function Paragraph16() {
  return (
    <div className="content-stretch flex flex-col items-end relative shrink-0 w-full" data-name="Paragraph">
      <p className="[word-break:break-word] font-['Inter:Semi_Bold','Noto_Sans_JP:Bold',sans-serif] font-semibold leading-[16.5px] not-italic relative shrink-0 text-[11px] text-[rgba(255,255,255,0.7)] text-right whitespace-nowrap">最高匹配 ↑+8%</p>
    </div>
  );
}

function Container24() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-[81.945px]" data-name="Container">
      <Paragraph15 />
      <Paragraph16 />
    </div>
  );
}

function Container23() {
  return (
    <div className="content-stretch flex h-[59px] items-start justify-between pb-[8px] pt-[4px] relative shrink-0 w-[318.06px]" data-name="Container">
      <Paragraph14 />
      <Container24 />
    </div>
  );
}

function Text8() {
  return (
    <div className="absolute bg-[rgba(255,255,255,0.2)] h-[25.995px] left-0 rounded-[39010100px] top-[0.65px] w-[86.995px]" data-name="Text">
      <p className="[word-break:break-word] absolute font-['Inter:Semi_Bold','Noto_Sans_JP:Bold','Noto_Sans_SC:Bold',sans-serif] font-semibold leading-[18px] left-[11.99px] not-italic text-[12px] text-white top-[4.16px] whitespace-nowrap">查看结果 →</p>
    </div>
  );
}

function Container25() {
  return (
    <div className="h-[26.642px] relative shrink-0 w-full" data-name="Container">
      <Text8 />
    </div>
  );
}

function Container22() {
  return (
    <div className="absolute content-stretch flex flex-col items-start left-[15.99px] top-[15.99px] w-[318.06px]" data-name="Container">
      <Paragraph13 />
      <Container23 />
      <Container25 />
    </div>
  );
}

function Container20() {
  return (
    <div className="absolute h-[133.625px] left-0 overflow-clip rounded-[24px] top-0 w-[350.031px]" style={{ backgroundImage: "linear-gradient(159.1054896529834deg, rgb(79, 126, 245) 0%, rgb(167, 123, 230) 100%)" }} data-name="Container">
      <Container21 />
      <Container22 />
    </div>
  );
}

function Button3() {
  return (
    <div className="absolute h-[133.625px] left-[-0.02px] top-[-0.01px] w-[350.031px]" data-name="Button">
      <Container20 />
    </div>
  );
}

function Container19() {
  return (
    <div className="absolute h-0 left-[20px] right-[20px] top-[538.91px]" data-name="Container">
      <Button3 />
    </div>
  );
}

function Container7() {
  return (
    <div className="absolute h-[679px] left-[0.29px] overflow-clip right-[-0.29px] top-[131.28px]" data-name="Container">
      <Paragraph1 />
      <CardMargin />
      <CardMargin1 />
      <ContainerMargin1 />
      <PrimaryBtnMargin />
      <Container19 />
    </div>
  );
}

function AnalysisHome() {
  return (
    <div className="h-[810px] relative shrink-0 w-full" data-name="AnalysisHome">
      <Container5 />
      <Container7 />
    </div>
  );
}

function Container4() {
  return (
    <div className="content-stretch flex flex-col h-[810.49px] items-start overflow-clip pb-[96px] relative shrink-0 w-full" data-name="Container">
      <AnalysisHome />
    </div>
  );
}

function Container3() {
  return (
    <div className="absolute content-stretch flex flex-col h-[810px] items-start left-0 overflow-clip right-0 top-[34px]" data-name="Container">
      <Container4 />
    </div>
  );
}

function Container27() {
  return <div className="absolute bg-[rgba(254,254,254,0.25)] h-[64.306px] left-[-1px] rounded-[31px] top-[-1px] w-[236.279px]" data-name="Container" />;
}

function IconHome() {
  return (
    <div className="relative shrink-0 size-[21.998px]" data-name="IconHome">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.9984" preserveAspectRatio="none" viewBox="0 0 21.9984 21.9984" width="21.9984">
        <g id="IconHome">
          <path d={svgPaths.pc7e1900} id="Vector" stroke="#7B7979" strokeLinejoin="round" strokeWidth="1.55822" />
        </g>
      </svg>
    </div>
  );
}

function Button4() {
  return (
    <div className="border-[1.163px] border-[rgba(0,0,0,0)] border-solid content-stretch flex h-[49.991px] items-center justify-center relative rounded-[22px] shrink-0 w-[71.99px]" data-name="Button">
      <IconHome />
    </div>
  );
}

function IconChart() {
  return (
    <div className="relative shrink-0 size-[21.998px]" data-name="IconChart">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.9984" preserveAspectRatio="none" viewBox="0 0 21.9984 21.9984" width="21.9984">
        <g id="IconChart">
          <path d={svgPaths.p30415b00} fill="url(#paint0_linear_0_7)" id="Vector" />
          <path d={svgPaths.pca7c500} fill="url(#paint1_linear_0_7)" id="Vector_2" />
          <path d={svgPaths.p21894d00} fill="url(#paint2_linear_0_7)" id="Vector_3" />
        </g>
        <defs>
          <linearGradient gradientUnits="userSpaceOnUse" id="paint0_linear_0_7" x1="2.7498" x2="19.2486" y1="3.6664" y2="19.2486">
            <stop stopColor="#4F7EF5" />
            <stop offset="1" stopColor="#A77BE6" />
          </linearGradient>
          <linearGradient gradientUnits="userSpaceOnUse" id="paint1_linear_0_7" x1="2.7498" x2="19.2486" y1="3.6664" y2="19.2486">
            <stop stopColor="#4F7EF5" />
            <stop offset="1" stopColor="#A77BE6" />
          </linearGradient>
          <linearGradient gradientUnits="userSpaceOnUse" id="paint2_linear_0_7" x1="2.7498" x2="19.2486" y1="3.6664" y2="19.2486">
            <stop stopColor="#4F7EF5" />
            <stop offset="1" stopColor="#A77BE6" />
          </linearGradient>
        </defs>
      </svg>
    </div>
  );
}

function Button5() {
  return (
    <div className="content-stretch flex h-[49.991px] items-center justify-center relative rounded-[99px] shrink-0 w-[71.99px]" data-name="Button">
      <div aria-hidden className="absolute backdrop-blur-[6px] bg-[rgba(255,255,255,0.5)] inset-0 pointer-events-none rounded-[99px]" />
      <div aria-hidden className="absolute border-[1.163px] border-[rgba(255,255,255,0.4)] border-solid inset-0 pointer-events-none rounded-[99px] shadow-[0px_1px_6px_0px_rgba(0,0,0,0.07)]" />
      <IconChart />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1px_0px_0px_rgba(255,255,255,0.55)]" />
    </div>
  );
}

function IconUser() {
  return (
    <div className="relative shrink-0 size-[21.998px]" data-name="IconUser">
      <svg className="absolute block inset-0 size-full" fill="none" height="21.9984" preserveAspectRatio="none" viewBox="0 0 21.9984 21.9984" width="21.9984">
        <g id="IconUser">
          <path d={svgPaths.p2aa6f000} id="Vector" stroke="#7B7979" strokeWidth="1.55822" />
          <path d={svgPaths.p32310300} id="Vector_2" stroke="#7B7979" strokeLinecap="round" strokeWidth="1.55822" />
        </g>
      </svg>
    </div>
  );
}

function Button6() {
  return (
    <div className="border-[1.163px] border-[rgba(0,0,0,0)] border-solid content-stretch flex h-[49.991px] items-center justify-center relative rounded-[22px] shrink-0 w-[71.99px]" data-name="Button">
      <IconUser />
    </div>
  );
}

function Container28() {
  return (
    <div className="absolute content-stretch flex gap-[2px] items-center left-0 px-[6px] py-[5px] rounded-[30px] top-0" data-name="Container">
      <div aria-hidden className="absolute backdrop-blur-[10px] bg-[rgba(255,255,255,0.04)] inset-0 pointer-events-none rounded-[30px]" />
      <div aria-hidden className="absolute border-[1.163px] border-[rgba(255,255,255,0.3)] border-solid inset-0 pointer-events-none rounded-[30px] shadow-[0px_6px_24px_0px_rgba(0,0,0,0.08),0px_1px_4px_0px_rgba(0,0,0,0.04)]" />
      <Button4 />
      <Button5 />
      <Button6 />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1.5px_0px_0px_rgba(255,255,255,0.62),inset_0px_-1px_0px_0px_rgba(255,255,255,0.12),inset_1px_0px_0px_0px_rgba(255,255,255,0.18),inset_-1px_0px_0px_0px_rgba(255,255,255,0.1)]" />
    </div>
  );
}

function Container26() {
  return (
    <div className="h-[62.308px] relative rounded-[30px] shrink-0 w-[234.28px]" data-name="Container">
      <Container27 />
      <Container28 />
    </div>
  );
}

function Text9() {
  return (
    <div className="content-stretch flex flex-col items-center relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Plus_Jakarta_Sans:Regular','Noto_Sans:Regular','Noto_Sans_Math:Regular','Noto_Sans_Symbols:Regular','Noto_Sans_Symbols2:Regular',sans-serif] font-normal leading-[24px] relative shrink-0 text-[22px] text-center text-white whitespace-nowrap">✦</p>
    </div>
  );
}

function Text10() {
  return (
    <div className="content-stretch flex flex-col items-center pt-[2px] relative shrink-0" data-name="Text">
      <p className="[word-break:break-word] font-['Inter:Bold',sans-serif] font-bold leading-[13.5px] not-italic relative shrink-0 text-[9px] text-[rgba(255,255,255,0.92)] text-center whitespace-nowrap">AI</p>
    </div>
  );
}

function Button7() {
  return (
    <div className="content-stretch flex flex-col items-center justify-center opacity-88 relative rounded-[99px] shrink-0 size-[61.999px]" data-name="Button">
      <div aria-hidden className="absolute backdrop-blur-[10px] inset-0 pointer-events-none rounded-[99px]" style={{ backgroundImage: "linear-gradient(135deg, rgba(79, 126, 245, 0.72) 0%, rgba(167, 123, 230, 0.72) 100%)" }} />
      <div aria-hidden className="absolute border-[1.163px] border-[rgba(255,255,255,0.42)] border-solid inset-0 pointer-events-none rounded-[99px] shadow-[0px_8px_24px_0px_rgba(79,126,245,0.3),0px_2px_6px_0px_rgba(0,0,0,0.06)]" />
      <Text9 />
      <Text10 />
      <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1.5px_0px_0px_rgba(255,255,255,0.5),inset_0px_-1px_0px_0px_rgba(79,126,245,0.2)]" />
    </div>
  );
}

function BottomNav() {
  return (
    <div className="absolute content-stretch flex gap-[10px] items-center justify-center left-0 pb-[20px] pt-[8px] top-[753.7px] w-[389.995px]" data-name="BottomNav">
      <Container26 />
      <Button7 />
    </div>
  );
}

function Container() {
  return (
    <div className="h-[844px] max-h-[844px] max-w-[390px] overflow-clip relative shrink-0 w-[390px]" style={{ backgroundImage: "linear-gradient(128.67221711531536deg, rgb(220, 233, 251) 7.735%, rgb(229, 220, 250) 45.774%, rgb(251, 233, 241) 92.265%)" }} data-name="Container">
      <Container1 />
      <Container3 />
      <BottomNav />
    </div>
  );
}

function App() {
  return (
    <div className="bg-[#d0dcec] content-stretch flex h-[875.431px] items-center justify-center relative shrink-0 w-[403.419px]" data-name="App">
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