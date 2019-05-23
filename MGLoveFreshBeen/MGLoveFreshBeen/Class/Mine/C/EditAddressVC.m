//
//  EditAddressVC.m
//  MGLoveFreshBeen
//
//  Created by ming on 16/7/14.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "EditAddressVC.h"
#import "MyAddressCell.h"

typedef enum{
    SexWoman,
    SexMan
}SexType;

@interface EditAddressVC ()<UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIScrollView *_scrollView;
    AddressCellModel *_address;
    UIButton *_manBtn; // 选择女生
    UIButton *_womanBtn; // 选择男生
    UIPickerView *selectCityPickView; // 城市选择的pickerView
    NSInteger _currentSelectedCityIndex; // pickerView当前选择下标
}
/** 城市数组 */
@property (nonatomic,strong) NSArray *cityArr;
@end

@implementation EditAddressVC
#pragma mark - lazy   
// pickerView的 数据源
- (NSArray *)cityArr{
    if (!_cityArr) {
        _cityArr = [NSArray arrayWithObjects:@"梅州市", @"清远市", @"北京市", @"上海市", @"潮汕市", @"珠海市",@"长沙市",@"南京市",@"天津市", @"广州市", @"佛山市", @"深圳市", @"廊坊市", @"武汉市", @"苏州市", @"无锡市",@"茂名市",@"阳江市", @"武汉市",@"杭州市",@"南昌市", nil];
    }
   return _cityArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _address = [[AddressCellModel alloc] init];
    
    [self setupRightNavigationItem];
    
    [self setupMainView];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.view.backgroundColor = MGRGBColor(171, 171, 171);
    UITextField *field=(UITextField *)[_scrollView viewWithTag:103];
    if(_address.address!=nil&&_address.address.length>0)
        field.text=_address.address;
}


- (void)setupRightNavigationItem {
    //导航按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAddress)];
    rightItem.tintColor = [UIColor orangeColor];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - 私有方法
#pragma mark 布局控件
- (void)setupMainView {
    _scrollView =[[UIScrollView alloc] initWithFrame:(CGRectMake(0, 0, MGSCREEN_width, MGSCREEN_height-64))];
    _scrollView.showsHorizontalScrollIndicator=NO;
    [self.view addSubview:_scrollView];
    NSArray *placeholderArr = @[@"请输入你的大名~",@"我靠BUG",@"鲜蜂侠联系你的电话",@"请选择城市",@"请选择你的住宅,大厦或学校",@"请输入楼号门牌号等详细信息"];
    NSArray *arr=@[@"姓名：",@"wokao" ,@"联系电话：",@"所在城市：", @"所在地区：",@"详细地址："];
    NSMutableArray *plString=[NSMutableArray array];
    if(self.userInfo != nil){
        _address = self.userInfo;
        plString =[NSMutableArray arrayWithArray:@[_address.accept_name,_address.gender,_address.telphone,_address.province_name,_address.city_name,_address.address]];
    }else{
        plString =[NSMutableArray arrayWithArray:arr];
    }
    for (int i = 0; i<6; i++) {
        UILabel *titleLabel = nil;
        if(1 == i){
            CGRect frame = CGRectMake(self.view.width * 0.20, 46 + MGMargin*2+4, 80, 36);
            _manBtn = [self setSexButtonWithFrame:frame withTitle:@"男" imageName:@"v2_noselected" selImage:@"v2_selected" type:SexMan];
            
            CGRect frame2 = CGRectMake(self.view.width - self.view.width*0.4, _manBtn.orgin.y, 80, 36);
            _womanBtn = [self setSexButtonWithFrame:frame2 withTitle:@"女" imageName:@"v2_noselected" selImage:@"v2_selected" type:SexWoman];
            
            if ([plString[i] isEqualToString:@"1"]) {
                _manBtn.selected = YES;
            }else if([plString[i] isEqualToString:@"0"]) {
                _womanBtn.selected = YES;
            }
            
            [_scrollView addSubview:_manBtn];
            [_scrollView addSubview:_womanBtn];

        }else{
            titleLabel = [[UILabel alloc] initWithFrame:(CGRectMake(10, 20+46*i,80 ,46))];
            titleLabel.font = MGFont(16);
            titleLabel.textColor = [UIColor orangeColor];
            titleLabel.text = arr[i];
            [_scrollView addSubview:titleLabel];
            
            UITextField *textfield=[[UITextField alloc] initWithFrame:(CGRectMake(90, titleLabel.frame.origin.y, MGSCREEN_width-120-10, 46))];
            textfield.font = titleLabel.font;
            textfield.delegate= self;
            textfield.tag = 201+i;
            textfield.returnKeyType = UIReturnKeyDone;
            if(self.userInfo!=nil)
            textfield.text = plString[i];
            textfield.tintColor= MGBackGray;
            textfield.textColor= MGRGBColor(39, 39, 40);
            textfield.placeholder = placeholderArr[i];
            [textfield setValue:MGRGBColor(171, 171, 171) forKeyPath:@"placeholderLabel.textColor"];
            [_scrollView addSubview:textfield];
            if(2 == i){
                textfield.keyboardType = UIKeyboardTypeNumberPad;
            }else if (4 == i){
                selectCityPickView = [[UIPickerView alloc] init];
                selectCityPickView.delegate = self;
                selectCityPickView.dataSource = self;
                textfield.inputView = selectCityPickView;
                // 创建附加键盘的确定取消按钮
                textfield.inputAccessoryView = [self buildInputView];
            }
        }
        // 分割线
        UIView *line=[[UIView alloc] initWithFrame:(CGRectMake(10,30+46*i+35.5 , MGSCREEN_width-10, 0.5f))];
        line.backgroundColor = MGBackGray;
        [_scrollView addSubview:line];
    }
    
    //确认
    UIButton *conformBtn=[UIButton buttonWithType:(UIButtonTypeCustom)];
    conformBtn.frame = CGRectMake(0, MGSCREEN_height-50-64, MGSCREEN_width, 50);
    conformBtn.backgroundColor = MGNavBarTiniColor;
    [conformBtn setTitle:@"保存" forState:(UIControlStateNormal)];
    [conformBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    conformBtn.titleLabel.font=[UIFont systemFontOfSize:16];
    [conformBtn addTarget:self action:@selector(confirmAddress) forControlEvents:(UIControlEventTouchUpInside)];
    [_scrollView addSubview:conformBtn];

}

#pragma mark - 按钮相关
- (UIButton *)setSexButtonWithFrame:(CGRect)frame withTitle:(NSString *)title imageName:(NSString *)imageName selImage:(NSString *)selImageName type:(SexType)type{
    UIButton *btn=[UIButton buttonWithType:(UIButtonTypeCustom)];
    btn.frame = frame;
    [btn addTarget:self action:@selector(chooseSex:) forControlEvents:(UIControlEventTouchUpInside)];
    [_scrollView addSubview:btn];
    btn.selected = NO;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -28);
    [btn setTitleColor:MGRGBColor(171, 171, 171) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:selImageName] forState:UIControlStateSelected];
    btn.tag = type;
    return btn;
}

// 点击性别操作
- (void)chooseSex:(UIButton *)sender{
    switch (sender.tag) {
    case SexMan:
        {
            _manBtn.selected = true;
            _womanBtn.selected = false;
            _address.gender = @"1";
        }
        break;
    case SexWoman:
        {
            _address.gender = @"0";
            _manBtn.selected = false;
            _womanBtn.selected = true;
        }
        break;
    default:
        break;
    }

}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(textField.frame.origin.y > MGSCREEN_height-250-64-40){
        
        [UIView animateWithDuration:0.15 animations:^{
            _scrollView.contentOffset=CGPointMake(0,textField.frame.origin.y-(MGSCREEN_height-250-64-40)+15);
        } completion:^(BOOL finished) {
            
        }];
    }
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [UIView animateWithDuration:0.15 animations:^{
        _scrollView.contentOffset=CGPointMake(0,0);
    } completion:^(BOOL finished) {
        
    }];
    
    if(textField.tag==203)
    {
        if([textField.text length]!=11)
        {
            MGPE(@"请输入正确的手机号");
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string{
    
    if ([[[UITextInputMode currentInputMode] primaryLanguage] isEqualToString:@"emoji"]){
        
        return NO;
    }
    return YES;
}


#pragma mark - Navigation
- (void)confirmAddress{
    [self.view endEditing:YES];
    
    UITextField *username = (UITextField *)[_scrollView viewWithTag:201];
    UITextField *telphone = (UITextField *)[_scrollView viewWithTag:203];
    UITextField *province = (UITextField *)[_scrollView viewWithTag:204];
    UITextField *city = (UITextField *)[_scrollView viewWithTag:205];
    UITextField *detail = (UITextField *)[_scrollView viewWithTag:206];
    _address.accept_name = username.text;
    _address.telphone = telphone.text;
    _address.province_name = province.text;
    _address.city_name = city.text;
    _address.address= detail.text;
    if(_address.accept_name.length > 0){
        
        if(_address.telphone.length == 11){
            
            if(_address.province_name.length > 0){
                
                if(_address.city_name.length > 0){
                    
                    if(_address.address.length>0){
                        
                        _address.address=[_address.address stringByAppendingFormat:@"%@",_address.address];
        
                        if(self.userInfo!=nil){ // 实际开发中是把这个上传到服务器并   发布通知pop的控制器重新网络加载数据
                            [MBProgressHUD showSuccess:@"收货地址编辑完成！"];
//                            MGPS(@"收货地址编辑完成！");
                            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                            [dict setObject:_address forKey:@"address"];
                            [MGNotificationCenter postNotificationName:MGEditAddressNotification object:nil userInfo:dict];
                        }
                        else{
                            [MBProgressHUD showError:@"收货地址添加成功！"];
//                            MGPS(@"收货地址添加成功！");
                            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                            [dict setObject:_address forKey:@"address"];
                            [MGNotificationCenter postNotificationName:MGAddAddressNotification object:nil userInfo:dict];
                            
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    }else
                        MGPE(@"请填写详细地址");
                    
                }else
                    MGPE(@"请选择省份");
            }else
                MGPE(@"请填写城市");
            
        }else
            MGPE(@"请填写正确的联系方式");
    }else
        MGPE(@"请填写姓名");
}


- (UIView *)buildInputView  {
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, MGSCREEN_width, 40)];
    toolBar.backgroundColor = [UIColor whiteColor];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MGSCREEN_width, 1)];
    lineView.backgroundColor = [UIColor blackColor];
    lineView.alpha = 0.2;
    [toolBar addSubview:lineView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = MGFont(15);
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.alpha = 0.8;
    titleLabel.text = @"选择城市";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.frame = CGRectMake(0, 0, MGSCREEN_width, toolBar.height);
    [toolBar addSubview:titleLabel];
    
    UIButton *cancleButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 80, toolBar.height)];
    cancleButton.tag = 10;
    [cancleButton addTarget:self action:@selector(selectedCityTextFieldDidChange:) forControlEvents:UIControlEventTouchUpInside];
    [cancleButton setTitle:@"取消"  forState: UIControlStateNormal];
    [cancleButton setTitleColor:MGRGBColor(88, 233, 168) forState:UIControlStateNormal];
    [toolBar addSubview:cancleButton];
    
    UIButton *determineButton = [[UIButton alloc] initWithFrame:CGRectMake(MGSCREEN_width - 80, 0, 80, toolBar.height)];
    determineButton.tag = 11;
    [determineButton addTarget:self action:@selector(selectedCityTextFieldDidChange:) forControlEvents:UIControlEventTouchUpInside];
    [determineButton setTitle:@"确定"  forState: UIControlStateNormal];
    [determineButton setTitleColor:MGRGBColor(82, 203, 238) forState:UIControlStateNormal];
    [toolBar addSubview:determineButton];
    
    return toolBar;
}

- (void)selectedCityTextFieldDidChange:(UIButton *)sender{
    UITextField *cityTextField = (UITextField *)[_scrollView viewWithTag:205];
    if (sender.tag == 11) {
        if (_currentSelectedCityIndex != -1) {
            cityTextField.text = self.cityArr[_currentSelectedCityIndex];
        }
    }
    [cityTextField endEditing:YES];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.cityArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.cityArr[row];
}

// 每一组返回的行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _currentSelectedCityIndex = row;
}

@end
