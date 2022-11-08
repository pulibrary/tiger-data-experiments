require './mediaflux'
require 'byebug'

MF = MediaFlux

describe "MF.to_xml" do
  it "handles nested elements" do
    expect(MF.to_xml({a: {b: {c: "xyz"}}})).to eq("<a><b><c>xyz</c></b></a>")
  end

  it "handles multiple elements" do
    expect(MF.to_xml({a: 1, b: 2, c: 3})).to eq("<a>1</a><b>2</b><c>3</c>")
  end

  it "translates underscores to dashes in element names" do
    expect(MF.to_xml({a_b_c: "xyz"})).to eq("<a-b-c>xyz</a-b-c>")
  end

  it "makes leading underscores into attributes" do
    expect(MF.to_xml({a: {_x: 1, _y: 2}})).to eq('<a x="1" y="2"></a>')
  end

  it "allows element text content to be created with single underscore" do
    expect(MF.to_xml({a: {_: 456, _attr: 123}})).to eq('<a attr="123">456</a>')
  end

  it "allows subelement to be created with single underscore" do
    expect(MF.to_xml({a: {_: {sub_el: 456}, _attr: 123}})).to eq('<a attr="123"><sub-el>456</sub-el></a>')
  end

  it "creates multiple elements with the same name if given an array" do
    expect(MF.to_xml({a: [1], b: [{_a: "a"}, {_b: "b", _: "c"}]})).to eq('<a>1</a><b a="a"></b><b b="b">c</b>')
  end

  it "creates element with underscore in name if given string rather than symbol as key" do
    expect(MF.to_xml({"a_b_c" => 123})).to eq('<a_b_c>123</a_b_c>')
  end

  it "creates attribute with underscore in name if given string rather than symbol as key" do
    expect(MF.to_xml(a: {"_a_b_c" => 123})).to eq('<a a_b_c="123"></a>')
  end

  it "escapes characters in element content" do
    expect(MF.to_xml(a: "<&>")).to eq('<a>&lt;&amp;&gt;</a>')
  end

  it "escapes characters in attribute value" do
    expect(MF.to_xml(a: {_xyz: "<&>"})).to eq('<a xyz="&lt;&amp;&gt;"></a>')
  end

  it "leaves off nil-valued attributes" do
    expect(MF.to_xml(a: {_x: 123, _y: nil})).to eq('<a x="123"></a>')
  end

  it "passes REXML through" do
    expect(MF.to_xml(a: REXML::Document.new("<b><c>123</c></b>"))).to eq('<a><b><c>123</c></b></a>')
  end
end